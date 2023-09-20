module Linehaul
  class AuthService
    include ResponseHelper

    USER_DETAILS_URL = LINEHAUL_BASE_URL + "/api/v5/partner/user_details"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_account
      response = Typhoeus::Request.new(
        USER_DETAILS_URL,
        headers: {
          Authorization: "NGuyXn9TsUVt_UpYjCzs"
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      response = respond(response)
      response["data"]
    end
  end
end