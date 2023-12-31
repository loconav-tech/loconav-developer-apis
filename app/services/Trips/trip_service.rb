module Trips
  class TripService
    attr_accessor :current_account, :params, :status_code, :errors, :pagination

    FETCH_TRIP_PARAMS = %i[unique_id start_time end_time states driver_id vehicle_id vehicle_number sort_column page
                           perPage] + [filters: {}]
    CREATE_TRIP_PARAMS = %i[
      create_new_vehicle_route new_vehicle_route_name should_start_at unique_id expected_distance
      trip_delay_alerts_enabled source_name destination_name].freeze +
      [vehicle: %i[id number]].freeze +
      [source: %i[ address coordinates eta etd geofence_id geofence_name tasks]].freeze +
      [destination: %i[ geofence_id geofence_name address coordinates eta  etd create_gate_pass ]].freeze +
      [cosigner: %i[ name phone_number email ]].freeze +
      [check_points: %i[ name address coordinates eta etd geofence_id geofence_name tasks]].freeze

    UPDATE_TRIP_PARAMS = %i[ id source
      create_new_vehicle_route new_vehicle_route_name should_start_at unique_id expected_distance
      trip_delay_alerts_enabled source_name destination_name].freeze +
      [vehicle: %i[id number]].freeze +
      [source: %i[ address coordinates eta etd geofence_id geofence_name tasks]].freeze +
      [destination: %i[ geofence_id geofence_name address coordinates eta etd create_gate_pass ]].freeze +
      [cosigner: %i[ name phone_number email ]].freeze +
      [check_points: %i[ name address coordinates eta etd geofence_id geofence_name tasks]].freeze

    DELETE_TRIP_PARAMS = %i[id].freeze

    def initialize(current_account, params)
      self.current_account = current_account
      self.pagination = pagination
      self.params = params
      self.pagination = nil
      self.errors = []
    end

    def fetch_trips
      return unless errors.empty?

      @params[:filters] = format_params
      success, response = Linehaul::TripService.new(@current_account["authentication_token"]).fetch_trips(params)
      if success
        @status_code = "success"
        @pagination = { page: params["page"].to_i,
                        perPage: params["perPage"].presence&.to_i || 10,
                        dataCount: response["data"].size }
        return response["data"]
      end
      handle_errors(status_code, response)
    end

    def create_trip
      return unless errors.empty?

      @status_code, response = Linehaul::TripService.new(@current_account["authentication_token"]).create_trip(params)
      if status_code
        return response
      end
      handle_errors(status_code, response)
    end

    def update_trip
      return unless errors.empty?

      @status_code, response = Linehaul::TripService.new(@current_account["authentication_token"]).update_trip(params)
      if status_code
        return response
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
                    "#{error_message['field']} #{error_message['message']}"
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
