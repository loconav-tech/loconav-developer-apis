module Polygon
  class UpdationService

    QUERY_PARAMS = %i[name lat radius long distance_unit active]

    attr_accessor :polygon_id,:params,:errors,:error_code,:current_account

    def initialize(current_account,polygon_id,request_params)
      self.current_account = current_account
      self.polygon_id = polygon_id
      self.params = request_params
      self.errors = []
    end

    def run!
      update_polygon
    end

    def update_polygon
      success, response = Linehaul::PolygonService.new(current_account["authentication_token"]).update_polygon(params,polygon_id)

      unless success
        if response == "Technical issue"
          handle_errors("Technical issue, please try again later")
        else
          errors << response
        end
        return
      end

      if success && response.present? && response["polygon"].present?
        response["polygon"]
      else
        handle_errors("Technical issue, please try again later")
      end

    end

    private def handle_errors(error_response)
      case error_response
      when /is missing/
        errors << error_response
        self.error_code = :parameter_is_missing
      else
        errors << "Technical issue, please try again later"
        self.error_code = :technical_issue
      end
    end

  end
end