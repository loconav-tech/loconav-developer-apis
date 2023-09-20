module Linehaul
  class DriverService
    include ResponseHelper

    FETCH_DRIVER_URL = LINEHAUL_BASE_URL + "/api/v5/drivers"

    attr_accessor :auth_token

    class ActionFailed < StandardError; end

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
      respond(response)
    end
  end
end