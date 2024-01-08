module Trips
  class TripService
    include UtilHelper

    attr_accessor :account, :params, :status_code, :errors, :pagination

    FETCH_TRIP_PARAMS = %i[unique_id start_time end_time states driver_id vehicle_id vehicle_number sort_column page perPage] + [filters: {}]

    def initialize(current_account, params)
      self.account = current_account
      self.pagination = pagination
      self.params = params
      self.errors = []
    end

    def fetch_trips
      return unless errors.empty?
      @params[:filters] = format_params
      params = get_indices(@params)
      success, response = Linehaul::TripService.new(@account["authentication_token"]).fetch_trips(params)
      if success
        @status_code = "success"
        @pagination = { page: params["page"].to_i,
                        perPage: params["perPage"].presence&.to_i || 10,
                        dataCount: response["data"].size }
        return response["data"]
      end
      handle_errors(status_code, response)
    end

    private def format_params
      params.slice(
        "unique_id",
        "start_time",
        "end_time",
        "states",
        "driver_id",
        "vehicle_id",
        "vehicle_number",
      ).transform_values(&:presence)
    end

    private def handle_errors(error_code, error_message)
      case error_code
      when 400, "failed"
        errors << if error_message["message"].present? && error_message["field"].present?
                    "#{error_message["field"]} #{error_message["message"]}"
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
      else
        self.status_code = :unprocessable_entity
        errors << (error_message.presence || "Unable to process request")
      end
    end
  end
end
