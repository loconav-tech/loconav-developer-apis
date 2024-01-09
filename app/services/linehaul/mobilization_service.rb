module Linehaul
  class MobilizationService
    class ActionFailed < StandardError; end

    include ResponseHelper

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    VEHICLE_V5_URL = LINEHAUL_BASE_URL + "/api/v5/trucks"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def create_mobilization_request(params)
      response = Typhoeus::Request.new(
        VEHICLE_V5_URL + "/" + params["id"].to_s + "/ev_mobilize",
        headers: {
          "Authorization": auth_token,
          "Content-Type": "application/json",
        },
        body: build_request_body(params).to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
        ).run
      parse_response(response)
    end

    def build_request_body(params)
      {
        type: params["type"],
        value: params["value"],
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
          [response.response_code, response_data["message"]]
        end
      else
        [false, "Technical issue"]
      end
    end
  end
end
