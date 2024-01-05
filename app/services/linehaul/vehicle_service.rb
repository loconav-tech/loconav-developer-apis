module Linehaul
  class VehicleService
    class ActionFailed < StandardError; end

    include ResponseHelper

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    FETCH_VEHICLE_URL = LINEHAUL_BASE_URL + "/api/v5/partner/vehicles"
    FETCH_VEHICLE_LITE_URL = LINEHAUL_BASE_URL + "/api/v5/partner/vehicles/lite"
    FETCH_VEHICLE_MOTION_URL = LINEHAUL_BASE_URL + "/api/v5/partner/vehicles?fetch_motion_status=true"
    FETCH_VEHICLE_SENSOR_URL = LINEHAUL_BASE_URL + "/api/v5/trucks/sensors/current_values"
    FETCH_HISTORY_STATS_URL = LINEHAUL_BASE_URL + "/api/v5/vehicle_data"
    ERROR_MSG_VEHICLE_LITE = "Error fetching data for vehicles".freeze

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_vehicle_details(vehicle_number,pagination)
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_URL + "?&number=" + vehicle_number.to_s + "&page=" + pagination[:page].to_s + "&per_page=" + pagination[:per_page].to_s + "&fetch_with_metrics=false",
        headers: {
          "Authorization": auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
        ).run
      respond(response,ActionFailed,ERROR_MSG_VEHICLE_LITE)
    end

    def fetch_vehicle_motion_details(vehicle_number)
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_MOTION_URL + "&number=" + vehicle_number.to_s,
        headers: {
          "Authorization": auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
    end

    def fetch_vehicle_sensor_details(vehicles, sensors, pagination)
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_SENSOR_URL + "?page=" + pagination[:page].to_s + "&per_page=" + pagination[:per_page].to_s,
        headers: {
          Authorization: auth_token,
          "Content-Type": "application/json",
        },
        body: build_sensor_details_request(vehicles, sensors).to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
      ).run
      parse_response(response)
    end

    def build_sensor_details_request(vehicles, sensors)
      {
        "vehicle_ids": vehicles,
        "sensors": sensors,
      }.compact
    end

    def fetch_history_stats(vehicle, sensors, start_time, end_time)
      response = Typhoeus::Request.new(
        FETCH_HISTORY_STATS_URL,
        headers: {
          Authorization: auth_token,
          'Content-Type' => 'application/json',
        },
        body: build_vehicle_data_request(vehicle, sensors, start_time, end_time).to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
        ).run
      parse_response(response)
    end

    private def build_vehicle_data_request(vehicle, sensors, start_time, end_time)
      {
        time_range: {
          start_time: start_time,
          end_time: end_time,
        },
        sensors: [
          {
            vehicle_uuid: vehicle,
            sensor_names: sensors
          },
        ]
      }
    end

    private def parse_response(response)
      if response && response.body.present?
        if response.success?
          response_data = JSON.parse(response.body)
          [true, response_data]
        elsif response.response_code == 500
          [false, "Technical issue"]
        else
          response_data = JSON.parse(response.body)
          [false, response_data["error"]]
        end
      else
        [false, "Technical issue"]
      end
    end
  end
end
