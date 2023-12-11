module Vt
  class LivestreamService

    include VtHelper

    attr_accessor :error_code, :errors

    def initialize
      self.errors = []
    end

    def create_livestream(params)
      response_code, response = livestream_post_endpoint(params)
      (handle_errors(response_code, response) && return) unless response_code == "success"
      response
    end

    def update_livestream(params)
      response_code, response = livestream_put_endpoint(params)
      (handle_errors(response_code, response) && return) unless response_code == "success"
      response
    end

    def delete_livestream(params)
      response_code, response = livestream_delete_endpoint(params["id"])
      (handle_errors(response_code, response) && return) unless response_code == "success"
      response
    end

    private def handle_errors(error_code, error_message)
      case error_code
      when 400, "failed"
        self.error_code = :invalid_request
        errors << "Invalid request Error: #{error_message}"
      when /not supported/
        self.error_code = :not_supported
        errors << "Currently not supported Error: #{error_message}"
      when /Data not found/
        self.error_code = :not_found
        errors << "Data not found Error: #{error_message}"
      when 308
        self.error_code = :technical_issue
        errors << "Technical issue, please try again later"
      else
        self.error_code = :technical_issue
        errors << "Technical issue, please try again later"
      end
    end
  end
end
