module Polygon
  class CreationService

    QUERY_PARAMS = %i[name lat radius long distance_unit active]
    REQUIRED_PARAMS = %w[name lat long radius]

    attr_accessor :params,:current_account,:errors,:error_code
    def initialize(current_account,request_params)
      self.current_account = current_account
      self.params = request_params
      self.errors = []
    end

    def run!
      validate_params
      create_polygon if errors.empty?
    end

    def validate_params
      check_missing_params
      # validate_data_types if errors.empty?
    end

    def check_missing_params
      REQUIRED_PARAMS.each do |key|
        handle_errors("#{key} is missing") unless params[key].present?
      end
    end

    # def validate_data_types
    #   handle_errors()
    # end

    def create_polygon
      success,response = Linehaul::PolygonService.new(current_account["authentication_token"]).create_polygon(params)

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