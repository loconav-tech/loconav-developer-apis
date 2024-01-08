module Drivers
  class UpdationService

    QUERY_PARAMS = [drivers:[%i[id name country_code phone_number]]].freeze

    attr_accessor :params,:errors,:error_code,:current_account

    def initialize(current_account,params)
      self.current_account = current_account
      self.params = params
      self.errors = []
    end

    def run!
      update_driver
    end

    def update_driver
      response_code,response = Linehaul::DriverService.new(current_account["authentication_token"]).update_driver(params)
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