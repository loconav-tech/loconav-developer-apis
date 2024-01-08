module Linehaul
  class DriverService
    class ActionFailed < StandardError; end

    include ResponseHelper

    V5_API_ACCESS_TOKEN = Rails.application.secrets.v5_api_access_token
    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    FETCH_DRIVER_URL = LINEHAUL_BASE_URL + "/api/v5/drivers"
    ERROR_MSG_DRIVER = "Error fetching data for driver".freeze
    DRIVER_URL = LINEHAUL_BASE_URL + "/api/v5/partner/drivers"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_drivers(params)
      response = Typhoeus::Request.new(
        FETCH_DRIVER_URL,
        headers: {
          Authorization: auth_token,
        },
        params:,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      respond(response, ActionFailed, ERROR_MSG_DRIVER)
    end

    def create_drivers(params)
      response = Typhoeus::Request.new(
        DRIVER_URL + "/onboard",
        headers: {
          Authorization: auth_token,
          "X-Linehaul-V5-Secret": V5_API_ACCESS_TOKEN,
          "User-Type": "User",
          "Content-Type": "application/json"
        },
        body: build_request_body(params).to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
        ).run
      parse_response(response)
    end

    def update_driver(params)
      response = Typhoeus::Request.new(
        DRIVER_URL + "/update",
        headers: {
          Authorization: auth_token,
          "X-Linehaul-V5-Secret": V5_API_ACCESS_TOKEN,
          "User-Type": "User",
          "Content-Type": "application/json"
        },
        body: build_request_body(params).to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :put,
        ).run
      parse_response(response)
    end

    def build_request_body(params)
      {
        "drivers": params[:drivers]
      }.compact
    end

    private def parse_response(response)
      if response && response.body.present?
        if response.success?
          response_data = JSON.parse(response.body)
          [true, response_data]
        elsif response.response_code == 400
          response_data = JSON.parse(response.body)
          [400, response_data&.dig("error")]
        elsif response.response_code == 422
          response_data = JSON.parse(response.body)
          [422, response_data&.dig("message","error")]
        else
          [false, "Technical issue"]
        end
      else
        [false, "Technical issue"]
      end
    end

  end
end
