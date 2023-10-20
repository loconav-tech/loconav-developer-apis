module Sensor
  class GpsSensor
    attr_accessor :types, :vehicle, :auth_token, :error_code, :errors

    def initialize(vehicle, auth_token, _types)
      self.vehicle = vehicle
      self.auth_token = auth_token
    end

    def last_known_stats
      success, response = Linehaul::VehicleService.new(auth_token).fetch_vehicle_motion_details(vehicle[:number])

      unless success
        [false, handle_errors(response)]
      end

      gps_stat = response["data"]["vehicles"][0]["additional_attributes"]["movement_metrics"]
      gps_stat_response = create_response(gps_stat)
      [true, gps_stat_response]
    end

    private def create_response(gps_stat)
      {
        "gps": {
          "speed": format_data("Speed", "Current speed of the vehicle", gps_stat["speed"]["unit"],
                               gps_stat["speed"]["value"], gps_stat["location"]["received_ts"]),
          "orientation": format_data("Orientation", "Current orientation of the vehicle", "degrees",
                                     gps_stat["orientation"], gps_stat["location"]["received_ts"]),
          "ignition": format_data("Ignition", "Ignition status of the vehicle", "", gps_stat["ignition"],
                                  gps_stat["location"]["received_ts"]),
          "lat": format_data("Latitude", "Latitude coordinates", "degrees", gps_stat["location"]["lat"],
                             gps_stat["location"]["received_ts"]),
          "long": format_data("Longitude", "Longitude coordinates", "degrees", gps_stat["location"]["long"],
                              gps_stat["location"]["received_ts"]),
        },
      }
    end

    private def format_data(display_name, description, unit, value, timestamp)
      {
        "display_name": display_name,
        "description": description,
        "unit": unit,
        "value": value,
        "timestamp": timestamp,
      }
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
  end
end
