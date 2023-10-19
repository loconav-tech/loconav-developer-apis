module Sensor
  class EngineSensor
    attr_accessor :types, :vehicle, :auth_token, :error_code, :errors

    def initialize(vehicle, auth_token, types)
      self.vehicle = vehicle
      self.auth_token = auth_token
      self.types = types
    end

    def last_known_stats
      # success, response = Linehaul::VehicleService.
      #   new(auth_token).
      #   fetch_vehicle_sensor_details(vehicle[:id])

      success, response = true, JSON.parse(sample_resp)

      unless success
        [false, handle_errors(response)]
      end

      engine_stat = response["data"]
      filtered_engine_stats = engine_stat.select { |key, _value| types.include?(key) }
      filtered_engine_stats = filtered_engine_stats.each do |_key, value|
        value.delete("sensor_type")
      end
      [true, filtered_engine_stats]
    end

    private def handle_errors(error_response)
      if error_response == "vehicle_ids is invalid"
        errors << "Invalid vehicleIds field"
        self.error_code = :invalid_vehicleIds
      elsif error_response == "vehicle_ids is missing"
        errors << "VehicleIds field missing"
        self.error_code = :missing_vehicleIds
      end
    end

    def sample_resp
      {
        "success": true,
        "data": {
          "power_cut_status_value": {
            "display_name": "Device External Power",
            "description": "",
            "unit": nil,
            "value": "ON",
            "sensor_type": "",
          },
          "temperature_value": {
            "display_name": "Temperature",
            "description": "It is used check the temperature of vehicle.",
            "unit": "",
            "value": "N/A",
            "sensor_type": "temperature",
            "timestamp": nil,
            "status": nil,
          },
          "ignition_value": {
            "display_name": "Ignition",
            "description": "It is used to check IGNITION of vehicle is ON/OFF (value is in bool).",
            "unit": "",
            "value": "ON",
            "sensor_type": "ignition",
          },
          "orientation_value": {
            "display_name": "Orientation Value",
            "description": "",
            "unit": nil,
            "value": "192",
            "sensor_type": "",
          },
          "battery_level_value": {
            "display_name": "Device Battery %",
            "description": "It shows the device battery level",
            "unit": "%",
            "value": "95",
            "sensor_type": "",
          },
        },
      }.to_json
    end
  end
end
