module Sensor
  class EngineSensor
    attr_accessor :types, :vehicle, :auth_token, :error_code, :errors

    def initialize(vehicle, auth_token, types)
      self.vehicle = vehicle
      self.auth_token = auth_token
      self.types = types
    end

    def last_known_stats
      success, response = Linehaul::VehicleService.new(auth_token).fetch_vehicle_sensor_details(vehicle[:id])
      ([false, fetch_error_message(response)] && return) unless success

      engine_stat = response["data"]
      filtered_engine_stats = engine_stat.select { |key, _value| types.include?(key) }
      filtered_engine_stats = filtered_engine_stats.each do |_key, value|
        value.delete("sensor_type")
      end
      [true, filtered_engine_stats]
    end

    # Vehicle sensor data API throw only Vehicle not found error
    private def fetch_error_message(error_msg)
      Rails.logger.error "Error in fetching last known stat for vehicle: " + vehicle[:uuid].to_s + " Error: " + error_msg
      "Technical issue"
    end
  end
end
