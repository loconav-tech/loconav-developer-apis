module Trips
  class TripService

    attr_accessor :current_account, :params, :status_code, :errors, :pagination

    FETCH_TRIP_PARAMS = %i[unique_id start_time end_time states driver_id vehicle_id vehicle_number sort_column page per_page].freeze

    def initialize(current_account, params)
      self.current_account = current_account
      self.pagination = pagination
      self.params = params
      self.pagination = { start_index: params["page"], perPage: params["per_page"] }
      self.errors = []
    end

    def fetch_trips
      return unless errors.empty?

      success, response = Linehaul::TripService.new(@current_account["authentication_token"]).fetch_trips(params)
      if success
        @status_code = "success"
        return response["data"]
      end
      handle_errors(status_code, response) && return unless success
    end

    def handle_errors(error_code, error_message)
      case error_code
      when 400, "failed"
        errors << if error_message["message"].present? && error_message["field"].present?
                    error_message["field"] + " " + error_message["message"]
                  else
                    "Invalid request Error: #{error_message}"
                  end
        self.status_code = :invalid_request
      when /not supported/
        self.status_code = :not_supported
        errors << "Currently not supported Error: #{error_message}"
      when /Data not found/
        self.status_code = :not_found
        errors << "Data not found Error: #{error_message}"
      when 308
        self.status_code = :technical_issue
        errors << "Technical issue, please try again later"
      else
        self.status_code = :unprocessable_entity
        errors << (error_message.presence || "Unable to process request")
      end
    end

  end

end