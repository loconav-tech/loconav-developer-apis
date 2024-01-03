module Linehaul
  class PolygonService

    CONNECTION_TIMEOUT = 20
    TIMEOUT = 20
    LINEHAUL_V2_SECRET = "X-Linehaul-V2-Secret"
    V2_API_ACCESS_TOKEN = Rails.application.secrets.v2_api_access_token
    LINEHAUL_BASE_URL = Rails.application.secrets.linehaul_base_url
    FETCH_POLYGONS_URL = LINEHAUL_BASE_URL + "/api/v5/polygons"
    POLYGON_URL = LINEHAUL_BASE_URL + "/api/v2/polygon"

    attr_accessor :auth_token

    def initialize(auth_token)
      self.auth_token = auth_token
    end

    def fetch_polygon_details(pagination, name, active)
      start_index = pagination[:page] * pagination[:per_page]
      end_index = (pagination[:page] + 1) * pagination[:per_page]
      response = Typhoeus::Request.new(
        FETCH_POLYGONS_URL + "?start_index=" + start_index.to_s + "&end_index=" + end_index.to_s + "&filter=" + name.to_s + "&active=" + active.to_s,
        headers: {
          "Authorization": auth_token,
          "X-Linehaul-V2-Secret": V2_API_ACCESS_TOKEN
        },
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :get,
      ).run
      parse_response(response)
    end

    def create_polygon(params)
      response = Typhoeus::Request.new(
        POLYGON_URL,
        headers: {
          "X-Linehaul-V2-Secret": V2_API_ACCESS_TOKEN,
          Authorization: auth_token,
        },
        body: build_request_body(params),
        timeout: TIMEOUT,
        connecttimeout: CONNECTION_TIMEOUT,
        method: :post,
      ).run
      parse_response(response)
    end

    def update_polygon(params, polygon_id)
      response = Typhoeus::Request.new(
        POLYGON_URL + "/" + polygon_id,
        headers: {
          "X-Linehaul-V2-Secret": V2_API_ACCESS_TOKEN,
          Authorization: auth_token,
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
        "name": params[:name],
        "lat": params[:lat],
        "long": params[:long],
        "radius": params[:radius],
        "active": params[:active],
        "distance_unit": params[:distance_unit],
      }.compact
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
          [false, response_data&.dig("message")]
        end
      else
        [false, "Technical issue"]
      end
    end

  end
end