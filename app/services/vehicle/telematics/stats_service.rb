module Vehicle
  module Telematics
    class StatsService
      include UtilHelper, ResponseHelper
      QUERY_PARAMS = [vehicleIds: [], sensors: []].freeze

      attr_accessor :auth_token, :pagination, :vehicles, :sensors, :error_code, :errors

      GPS_SENSORS = ["speed", "ignition", "orientation", "current_location_coordinates"].freeze

      def initialize(auth_token, vehicles, sensors, pagination)
        self.auth_token = auth_token
        self.pagination = pagination
        self.vehicles = vehicles
        self.sensors = sensors
        self.errors = []
      end

      def run!
        validate!
        fetch_sensors
        fetch_stats
      end

      private def validate!
        handle_errors("Invalid page request") unless pagination[:page].to_i > 0
        handle_errors("Invalid per_page request") unless pagination[:per_page].to_i > 0
      end

      private def fetch_stats
        return unless errors.empty?

        success, response = Linehaul::VehicleService.new(auth_token).fetch_vehicle_sensor_details(vehicles, sensors, pagination)
        (handle_errors(response) && return) unless success

        if response["data"].present? && response["data"]["vehicles"].present? && response["data"]["pagination"].present?
          if errors.empty?
            pagination_metadata = pagination_metadata(pagination,
                                                      response["data"]["pagination"]["total_count"])
          end
          [format_response(response["data"]["vehicles"]), pagination_metadata]
        else
          handle_errors("Technical issue")
        end
      end

      private def format_response(sensor_response)
        sensor_response.map do |vehicle|
          {
            vehicle_number: vehicle["vehicle_number"],
            vehicle_id: vehicle["vehicle_id"],
          }.merge(
            sensors.each_with_object({}) do |sensor, extracted|
              if GPS_SENSORS.include?(sensor) and vehicle.key?(sensor)
                extracted["gps"] = Sensor::GpsSensor.new(vehicle, sensors).format_gps_stats
              else
                next unless vehicle.key?(sensor)
                sensor_data = vehicle[sensor]
                next if (sensor_data == true || !validate_stats_response(sensor_data))
                extracted[sensor] = format_stats_response(sensor_data)
              end
            end,
          )
        end
      end

      private def fetch_sensors
        success, response = Sensor::SensorService.new(sensors).fetch_sensors
        (handle_errors(response) && return) unless success
        self.sensors = response
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
