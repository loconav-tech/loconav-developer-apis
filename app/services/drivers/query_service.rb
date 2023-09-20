module Drivers
  class QueryService
    QUERY_PARAMS = %i[name].freeze

    attr_accessor :account, :params

    def initialize(account, params)
      self.account = account
      self.params = params
    end

    def run!
      search_driver
    end

    private def search_driver
      driver = Linehaul::DriverService.new(account['authentication_token']).fetch_drivers({ name: params[:name] })
      Loconav::Response::Builder.success(values: driver["drivers"])
    end
  end
end