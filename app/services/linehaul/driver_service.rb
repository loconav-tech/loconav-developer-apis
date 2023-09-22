module Linehaul
  class DriverService
    class ActionFailed < StandardError; end

    include ResponseHelper

    FETCH_DRIVER_URL = LINEHAUL_BASE_URL + "/api/v5/drivers"
    DEFAULT_ERROR_MSG = "Error fetching data for driver".freeze

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_drivers(params)
      response = Typhoeus::Request.new(
        FETCH_DRIVER_URL,
        headers: {
          Authorization: auth_token
        },
        params: params,
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      respond(response, ActionFailed, DEFAULT_ERROR_MSG)
    end
  end
end