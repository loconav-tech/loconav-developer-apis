module Mobilization
  class CreationService

    include UtilHelper

    QUERY_PARAMS = %i[vehicle_number type value].freeze
    REQUIRED_PARAMS = %w[vehicle_number type value].freeze

    attr_accessor :params,:errors,:error_code,:current_account

    def initialize(params,current_account)
      self.params = params
      self.current_account = current_account
      self.errors = []
    end

    def run!
      validate!
      fetch_vehicle_id if errors.empty?
      create_mobilization_request if errors.empty?
    end

    def validate!
      check_missing_params
      validate_params if errors.empty?
    end

    def check_missing_params
      REQUIRED_PARAMS.each do |key|
        handle_errors(400,"#{key} is missing") unless params[key].present?
      end
    end

    def validate_params
      handle_errors(400,"type not supported") unless params["type"].in?(%w[charging discharging])
      handle_errors(400,"value not supported") unless params["value"].in?(%w[MOBILIZE IMMOBILIZE])
    end

    def fetch_vehicle_id
      pagination = build_pagination(params)
      response = Linehaul::VehicleService.new(current_account["authentication_token"]).fetch_vehicle_details(params["vehicle_number"],pagination)
      if response && response["success"].present? && response["success"] == true
        vehicles = response["data"]["vehicles"]
        if vehicles.size == 1 && vehicles[0]["number"] == params["vehicle_number"]
          params["id"] = response["data"]["vehicles"][0]["id"]
        else
          handle_errors(422,"no vehicle found with associated vehicle_number")
        end
      else
        handle_errors(422,"Technical issue")
      end
    end

    def create_mobilization_request
      transform_mobilization_value
      response_code,response = Linehaul::MobilizationService.new(current_account["authentication_token"]).create_mobilization_request(params)

      handle_errors(response_code,response) && return unless response_code == true

      if response_code == true
        response
      else
        handle_errors(422,"Technical_issue")
      end

    end
    
    def transform_mobilization_value
      params["value"] = params["value"] == "MOBILIZE"
    end

    def handle_errors(response_code,response)
      case response_code
      when 400
        errors << response
        self.error_code = :parameter_is_wrong_or_missing
      when 422
        errors << response
        self.error_code = :invalid_data
      when 404
        errors << response
        self.error_code = :data_not_found
      else
        errors << "Technical issue, please try again later"
        self.error_code = :technical_issue
      end
    end

  end
end