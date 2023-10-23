module Vehicle
  module Telematics
    class StatsService
      QUERY_PARAMS = [vehicleIds: [], sensors: []].freeze

      attr_accessor :auth_token, :pagination, :vehicles, :sensors, :error_code, :errors

      def initialize(auth_token, vehicles, sensors, pagination)
        self.auth_token = auth_token
        self.pagination = pagination
        self.vehicles = vehicles
        self.sensors = sensors
        self.errors = []
      end

      def run!
        success, response = Linehaul::VehicleService.new(auth_token).fetch_vehicle_lite(vehicles, pagination)
        (handle_errors(response) && return) unless success
        (handle_errors("Data not found") && return) unless response["data"].present? && response["data"]["vehicles"].present?

        fetch(response["data"]["vehicles"])
      end

      private def fetch(vehicles_map)
        success, response = Sensor::SensorService.new(sensors).fetch_sensors
        (handle_errors(response) && return) unless success

        vehicles.map do |vehicle_uuid|
          vehicle = {
            uuid: vehicle_uuid,
            id: vehicles_map[vehicle_uuid].first&.first,
            name: vehicles_map[vehicle_uuid].first&.second,
          }
          fetch_last_known_stats(vehicle, response)
        end
      end

      private def fetch_last_known_stats(vehicle, avail_sensors)
        stats = {
          vehicle_number: vehicle[:name],
          vehicle_id: vehicle[:uuid],
        }

        sensor_promises = []
        avail_sensors.each do |klass, types|
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
        if error_response == "vehicle_ids is invalid"
          errors << "Invalid vehicleIds field"
          self.error_code = :invalid_vehicleIds
        elsif error_response == "vehicle_ids is missing"
          errors << "VehicleIds field missing"
          self.error_code = :missing_vehicleIds
        elsif error_response == "Data not found"
          errors << "Data not found"
          self.error_code = :data_not_found
        elsif error_response == "Technical issue"
          errors << "Technical issue, please try again later"
          self.error_code = :technical_issue
        end
      end
    end
  end
end
