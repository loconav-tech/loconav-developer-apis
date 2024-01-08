module Drivers
  class CreationService

    QUERY_PARAMS = [drivers:[%i[name country_code phone_number]]].freeze
    attr_accessor :params,:current_account,:errors,:error_code

    def initialize(current_account,params)
      self.current_account = current_account
      self.params = params
      self.errors = []
    end

    def run!
      create_drivers
    end

    def create_drivers
      response_code,response = Linehaul::DriverService.new(current_account["authentication_token"]).create_drivers(params)

      handle_errors(response_code,response) && return unless response_code == true

      if response.present? && response["data"].present?
        response["data"]
      else
        handle_errors(500,"Technical_issue")
      end
    end

    def handle_errors(response_code,response)
      case response_code
      when 400
        errors << response
        self.error_code = :invalid_request
      when 422
        errors << response
        self.error_code = :not_supported
      else
        errors << "Technical issue, please try again later"
        self.error_code = :technical_issue
      end
    end

  end
end