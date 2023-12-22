module Linehaul
  class PolygonService

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_V2_SECRET = "X-Linehaul-V2-Secret".freeze
    V2_API_ACCESS_TOKEN = Rails.application.secrets.v2_api_access_token
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    FETCH_POLYGONS_URL = LINEHAUL_BASE_URL + "/api/v5/polygons"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_polygon_details(pagination,name,active)
      response = Typhoeus::Request.new(
        FETCH_POLYGONS_URL + "?page=" + pagination[:page].to_s + "&per_page=" + pagination[:per_page].to_s + "&filter=" + name.to_s + "&active=" + active.to_s,
        headers: {
          "Authorization": auth_token,
          LINEHAUL_V2_SECRET: V2_API_ACCESS_TOKEN
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
        ).run
      byebug
      [true,JSON.parse(response.body)]
    end

  end
end