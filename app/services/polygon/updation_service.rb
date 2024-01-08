module Polygon
  class UpdationService

    QUERY_PARAMS = %i[name lat radius long distance_unit active]

    attr_accessor :polygon_id, :params, :errors, :error_code, :current_account

    def initialize(current_account, polygon_id, request_params)
      self.current_account = current_account
      self.polygon_id = polygon_id
      self.params = request_params
      self.errors = []
    end

    def run!
      validate_distance_unit
      update_polygon if errors.empty?
    end

    def validate_distance_unit
      handle_errors("distance unit should be in meters[m]") if params["distance_unit"].present? && params["distance_unit"] != "m"
    end

    def update_polygon
      success, response = Linehaul::PolygonService.new(current_account["authentication_token"]).update_polygon(params, polygon_id)

      handle_errors(response) && return unless success

      if success && response.present? && response["polygon"].present?
        response["polygon"]
      else
        handle_errors("Technical issue")
      end

    end

    private def handle_errors(error_response)
      case error_response
      when /is invalid/
        errors << error_response
        self.error_code = :parameter_is_invalid
      when "distance unit should be in meters[m]"
        errors << error_response
        self.error_code = :parameter_is_invalid
      when "Technical issue"
        errors << "Technical issue, please try again later"
        self.error_code = :technical_issue
      else
        errors << error_response
        self.error_code = :something_went_wrong
      end
    end

  end
end
