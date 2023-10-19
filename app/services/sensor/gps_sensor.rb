module Sensor
  class GpsSensor
    attr_accessor :types, :vehicle, :auth_token, :error_code, :errors

    def initialize(vehicle, auth_token, _types)
      self.vehicle = vehicle
      self.auth_token = auth_token
    end

    def last_known_stats
      # success, response = Linehaul::VehicleService.
      #   new(auth_token).
      #   fetch_vehicle_motion_details(vehicle[:number])

      success, response = true, JSON.parse(sample_resp)

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
          "speed": format_data("Speed", "Current speed of the vehicle", gps_stat["speed"]["unit"], gps_stat["speed"]["value"], gps_stat["location"]["received_ts"]),
          "orientation": format_data("Orientation", "Current orientation of the vehicle", "degrees", gps_stat["orientation"], gps_stat["location"]["received_ts"]),
          "ignition": format_data("Ignition", "Ignition status of the vehicle", "", gps_stat["ignition"], gps_stat["location"]["received_ts"]),
          "lat": format_data("Latitude", "Latitude coordinates", "degrees", gps_stat["location"]["lat"], gps_stat["location"]["received_ts"]),
          "long": format_data("Longitude", "Longitude coordinates", "degrees", gps_stat["location"]["long"], gps_stat["location"]["received_ts"]),
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

    private def sample_resp
      {
        "success": true,
        "data": {
          "vehicles": [
            {
              "id": 733079,
              "number": "350317170007615",
              "device_id": "0350317170007615",
              "display_number": "PINV007615",
              "status": true,
              "last_located_at": "2023-10-19T22:54:12.000+05:30",
              "notes": "",
              "temperature_working_fine": "NA",
              "current_temperature": "N/A",
              "gps_status": "Stopped since 08:52 PM",
              "last_location": "3, B Rd, Bamangachi, Liluah, Howrah, West Bengal 711106, India",
              "last_status_received_at": "19/10/2023, 08:52PM",
              "device": {
                "serial_number": "0350317170007615",
                "country_code": "IN",
                "phone_number": "5754215545304",
                "device_type": "Teltonika-TFT100",
              },
              "subscription": {
                "expires_at": "2026-08-26T15:54:21.000+05:30",
              },
              "status_message": {
                "received_at": "19/10/2023, 10:54PM",
              },
              "additional_attributes": {
                "movement_metrics": {
                  "orientation": 0.0,
                  "speed": {
                    "value": 0.0,
                    "unit": "km/h",
                  },
                  "motion_status": "stopped",
                  "state_since_ts": 1697728920,
                  "ignition": "off",
                  "location": {
                    "lat": 22.609793,
                    "long": 88.332475,
                    "address": "3, B Rd, Bamangachi, Liluah, Howrah, West Bengal 711106, India",
                    "received_ts": 1697736252,
                  },
                },
              },
              "chassis_number": "",
              "current_odometer_reading": 0,
              "vehicle_type": "truck_generic",
              "created_at": 1693034101,
              "updated_at": 1695619612,
              "uses_bms_immobalization": true,
            },
          ],
          "pagination": {
            "per_page": 100,
            "total_count": 1,
            "current_page": 1,
          },
        },
      }.to_json
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
