module Polygon
  class QueryService

    attr_accessor :current_user, :pagination, :params, :errors, :error_code

    def initialize(current_user, pagination, params)
      self.current_user = current_user
      self.pagination = pagination
      self.params = params
      self.errors = []
    end

    def run!
      validate!
      fetch_details if errors.empty?
    end

    def fetch_details
      success, response = Linehaul::PolygonService.new(current_user["authentication_token"]).fetch_polygon_details(pagination, params[:name], params[:active])

      unless success
        if response == "Technical issue"
          handle_errors("Technical issue")
        else
          errors << response
        end
        return
      end

      if success && response["data"] && response["total_count"]
        pagination[:total_count] = response["total_count"]
        response["pagination"] = pagination
        response
      else
        handle_errors("techincal_issue")
      end
    end

    def validate!
      handle_errors("Invalid page request") unless pagination[:page].to_i > 0
      handle_errors("Invalid per_page request") unless pagination[:per_page].to_i > 0
    end

    private def handle_errors(error_response)
      case error_response
      when "Invalid page request"
        errors << error_response
        self.error_code = :invalid_pagination_request
      when "Invalid per_page request"
        errors << error_response
        self.error_code = :invalid_pagination_request
      else
        errors << "Technical issue, please try again later"
        self.error_code = :technical_issue
      end
    end

  end
end