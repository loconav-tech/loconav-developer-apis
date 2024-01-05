module Vehicle
  class QueryService

    QUERY_PARAMS = :vehicle_number
    attr_accessor :vehicle_number, :pagination, :error_code, :errors, :account

    def initialize(account,vehicle_number,pagination)
      self.vehicle_number = vehicle_number
      self.errors = []
      self.pagination = pagination
      self.account = account
    end

    def run!
      fetch_details
    end

    def fetch_details
      response = Linehaul::VehicleService.new(account["authentication_token"]).fetch_vehicle_details(vehicle_number,pagination)
      if response &&
        response["success"].present? &&
        response["success"] == true
        format_response(response)
        response["data"]
      else
        self.error_code = :error_while_getting_response
        errors << "error while getting response"
      end
    end

    def format_response(response)
      response["data"]["vehicles"].each do |vehicle|
        vehicle.delete_if { |_key, value| value.nil? || value == "N/A" || value == "" || value == "-"}
      end
    end

  end
end