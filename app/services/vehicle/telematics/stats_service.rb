module Vehicle
  module Telematics
    class StatsService
      include UtilHelper
      QUERY_PARAMS = [vehicleIds: [], sensors: []].freeze

      attr_accessor :auth_token, :pagination, :vehicles, :vehicles_map, :sensors, :error_code, :errors

      def initialize(auth_token, vehicles, sensors, pagination)
        self.auth_token = auth_token
        self.pagination = pagination
        self.vehicles = vehicles
        self.vehicles_map = {}
        self.sensors = sensors
        self.errors = []
      end

      def run!
        validate!
        fetch_sensors if errors.empty?
        fetch_vehicles if errors.empty?
        fetch_last_known if errors.empty?
      end

      private def validate!
        handle_errors("Invalid page request") unless pagination[:page].to_i > 0
        handle_errors("Invalid per_page request") unless pagination[:per_page].to_i > 0
      end

      private def fetch_sensors
        success, response = Sensor::SensorService.new(sensors).fetch_sensors
        (handle_errors(response) && return) unless success
        self.sensors = response
      end

      private def fetch_vehicles
        start_index, end_index = get_indices(pagination)
        self.vehicles = vehicles.present? ? vehicles[start_index...end_index] : []
        (handle_errors("Data not found") && return) if vehicles.nil?

        success, response = Linehaul::VehicleService.new(auth_token).fetch_vehicle_lite(vehicles)
        (handle_errors(response) && return) unless success
        (handle_errors("Data not found") && return) unless response["data"].present? && response["data"]["vehicles"].present?

        self.vehicles_map = response["data"]["vehicles"]

        if vehicles.empty? && vehicles_map.present?
          self.vehicles = vehicles_map.keys[start_index...end_index]
        end
      end

      private def fetch_last_known
        vehicles.map do |vehicle_uuid|
          vehicles_map[vehicle_uuid] ?
            fetch_last_known_stats({
                                     uuid: vehicle_uuid,
                                     id: vehicles_map[vehicle_uuid].first&.first,
                                     name: vehicles_map[vehicle_uuid].first&.second,
                                   }) :
            { vehicle_id: vehicle_uuid, error: "Vehicle not found" }
        end
      end

      private def fetch_last_known_stats(vehicle)
        stats = {
          vehicle_number: vehicle[:name],
          vehicle_id: vehicle[:uuid],
        }

        sensor_promises = []
        sensors.each do |klass, types|
          sensor_promises << (Concurrent::Promises.future do
            sensor_stats = nil
            begin
              sensor_klass = "Sensor::#{klass}".constantize
              success, sensor_stats = sensor_klass.new(vehicle, auth_token, types).last_known_stats
              (handle_errors(response) && return) unless success
              sensor_stats
            rescue NameError => e
              Rails.logger.error "Error while fetching sensor data " + e.to_s
            end
            sensor_stats
          end)
        end
        Concurrent::Promises.zip(*sensor_promises).then do |*sensor_results|
          sensor_results.each do |sensor_stats|
            stats.merge!(sensor_stats) if sensor_stats.present?
          end
          stats
        end.value
      end

      private def handle_errors(error_response)
        case error_response
        when "Invalid page request"
          errors << error_response
          self.error_code = :invalid_pagination_request
        when "Invalid per_page request"
          errors << error_response
          self.error_code = :invalid_pagination_request
        when "vehicle_ids is invalid"
          errors << "Invalid vehicleIds request"
          self.error_code = :invalid_vehicleIds
        when "vehicle_ids is missing"
          errors << "VehicleIds field missing"
          self.error_code = :missing_vehicleIds
        when /not supported/
          errors << error_response
          self.error_code = :sensor_not_supported
        when "Only 3 sensors supported at a time"
          errors << error_response
          self.error_code = :invalid_sensors_count
        when "Data not found"
          errors << "Data not found"
          self.error_code = :data_not_found
        else
          errors << "Technical issue, please try again later"
          self.error_code = :technical_issue
        end

      end
    end
  end
end
