module Vehicle
  module Telematics
    class HistoryStatsService
      include ResponseHelper
      QUERY_PARAMS = [:vehicleId, :start_time, :end_time, sensors: []].freeze

      attr_accessor :auth_token, :vehicle, :sensors, :error_code, :errors, :start_time, :end_time

      def initialize(auth_token, vehicle, start_time, end_time, sensors)
        self.auth_token = auth_token
        self.vehicle = vehicle
        self.start_time = start_time
        self.end_time = end_time
        self.sensors = sensors
        self.errors = []
      end

      def run!
        validate!
        validate_sensors if errors.empty?
        fetch_history_stats if errors.empty?
      end

      private def validate!
        handle_errors("Start time not present") unless start_time.present?
        handle_errors("End time not present") unless start_time.present?
        handle_errors("Start time should be less than end time") unless start_time.present?
      end

      private def fetch_history_stats
        success, response = Linehaul::VehicleService.new(auth_token).fetch_history_stats(vehicle, sensors, start_time, end_time)
        (handle_errors(response) && return) unless success

        if response["data"].present? && response["data"][0]["sensors"].present?
          {
            history_stats: response.deep_transform_keys! { |key| key.camelize(:lower) }["data"][0]["sensors"]
          }
        else
          handle_errors("Technical issue")
        end
      end

      private def validate_sensors
        success, response = Sensor::HistorySensorService.new(sensors).validate!

        handle_errors(response) unless success
      end

      private def handle_errors(error_response)
        case error_response
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
        when "Start time not present"
          errors << "Start time not present"
          self.error_code = :start_time_not_present
        when "End time not present"
          errors << "End time not present"
          self.error_code = :end_time_not_present
        when "Start time should be less than end time"
          errors << "Start time should be less than end time"
          self.error_code = :start_time_end_time_invalid
        else
          errors << "Technical issue, please try again later"
          self.error_code = :technical_issue
        end
      end
    end
  end
end
