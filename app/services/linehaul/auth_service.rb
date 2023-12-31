module Linehaul
  class AuthService
    include ResponseHelper
    class InvalidAuth < StandardError; end

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    INVALID_AUTH_ERROR_MSG = "Authentication Failed"
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    USER_DETAILS_URL = LINEHAUL_BASE_URL + "/api/v5/partner/user_details"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_account
      response = Typhoeus::Request.new(
        USER_DETAILS_URL,
        headers: {
          Authorization: auth_token,
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      return false unless response.success?
      response = respond(response, InvalidAuth, INVALID_AUTH_ERROR_MSG)
      response["data"]
    end
  end
end
