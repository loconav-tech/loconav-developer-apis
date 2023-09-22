module Drivers
  class QueryService
    QUERY_PARAMS = %i[name].freeze

    attr_accessor :account, :params, :errors, :error_code

    def initialize(account, params)
      self.account = account
      self.params = params
      self.errors = []
    end

    def run!
      driver = Linehaul::DriverService.new(account['authentication_token']).fetch_drivers({ name: params[:name] })
      if driver &&
        driver["success"].present? &&
        driver["success"] == true
        driver["drivers"]
      else
        self.errors << "Driver not found"
        self.error_code = :driver_not_found
      end
    end
  end
end
