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
      params = params.merge(get_pagination(params))
      response = Typhoeus::Request.new(
        LINEHAUL_BASE_URL + TRIP_URL,
        params: params.to_param,
        headers: {
          "Authorization": auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
    end

    def create_trip(params)
      response = Typhoeus::Request.new(
        LINEHAUL_BASE_URL + TRIP_URL,
        headers: {
          "Authorization": auth_token,
          "Content-Type": "application/json",
        },
        body: params.to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
      ).run
      parse_response(response)
    end

    def update_trip(params)
      response = Typhoeus::Request.new(
        LINEHAUL_BASE_URL + TRIP_URL,
        headers: {
          "Authorization": auth_token,
          "Content-Type": "application/json",
        },
        body: params.to_json,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :put,
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
          [response_data["success"], response_data["errors"]]
        end
      else
        [false, "Technical issue"]
      end
    end

    private def get_pagination(params)
      response = {}
      if params["page"].present? && params["perPage"].present?
        start_index = params["page"].to_i * params["perPage"].to_i
        end_index = (params["page"].to_i + 1) * params["perPage"].to_i
        response = { start_index: start_index, end_index: end_index }
      elsif params["page"].present?
        start_index = params["page"].to_i * 10
        response = { start_index: start_index }
      elsif params["perPage"].present?
        end_index = params["perPage"].to_i
        response = { end_index: end_index }
      end

      response
    end
  end
end
