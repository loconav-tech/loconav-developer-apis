module Linehaul
  class VehicleService
    class ActionFailed < StandardError; end

    include ResponseHelper

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    FETCH_VEHICLE_LITE_URL = LINEHAUL_BASE_URL + "/api/v5/partner/vehicles/lite"
    FETCH_VEHICLE_MOTION_URL = LINEHAUL_BASE_URL + "/api/v5/partner/vehicles?fetch_motion_status=true"
    FETCH_VEHICLE_SENSOR_URL = LINEHAUL_BASE_URL + "/api/v5/trucks"
    ERROR_MSG_VEHICLE_LITE = "Error fetching data for vehicles".freeze

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_vehicle_lite(vehicles, pagination)
      req_body = build_vehicle_lite_request(vehicles)
      Rails.logger.info req_body
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_LITE_URL + "?page=" + pagination[:page].to_s + "&per_page=" + pagination[:per_page].to_s,
        headers: {
          Authorization: auth_token,
        },
        body: req_body,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
      ).run
      parse_response(response)
    end

    def fetch_vehicle_motion_details(vehicle_number)
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_MOTION_URL + "&number=" + vehicle_number.to_s,
        headers: {
          Authorization: auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
    end

    def fetch_vehicle_sensor_details(vehicle_id)
      response = Typhoeus::Request.new(
        FETCH_VEHICLE_SENSOR_URL + "/" + vehicle_id.to_s + "/current_sensor_values",
        headers: {
          Authorization: auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
    end

    private def build_vehicle_lite_request(vehicles)
      {
        "vehicle_ids": vehicles,
      }
    end

    private def parse_response(response)
      if response && response.body.present?
        response_data = JSON.parse(response.body)
        if response.success?
          [true, response_data]
        else
          [false, response_data["error"]]
        end
      else
        raise klass, error_message
      end
    end
  end
end
