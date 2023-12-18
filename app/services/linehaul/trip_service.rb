# frozen_string_literal: true

module Linehaul
  class TripService

    class ActionFailed < StandardError; end

    include ResponseHelper

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    TRIP_URL = "/api/v5/trips"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_trips(params)
      response = Typhoeus::Request.new(
        LINEHAUL_BASE_URL + TRIP_URL,
        params: params,
        headers: {
          "Authorization": auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
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
