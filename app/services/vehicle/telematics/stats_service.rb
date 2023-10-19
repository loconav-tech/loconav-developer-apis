module Vehicle
  module Telematics
    class StatsService
      QUERY_PARAMS = [:vehicleIds => [], :sensors => []].freeze

      attr_accessor :account, :vehicles, :sensors, :error_code, :errors

      def initialize(account, vehicles, sensors)
        self.account = account
        self.vehicles = vehicles
        self.sensors = sensors
        self.errors = []
      end

      def run!
        # Get all vehicles by their UUIds
        success, response = Linehaul::VehicleService.new(account["authentication_token"])
                                               .fetch_vehicle_lite(vehicles)
        unless success
          handle_errors(response)
          return
        end

        vehicles_map = response if success

        vehicles_map.each do |key, val|
          vehicle_uuid = key
          vehicle_id = val[0]
          vehicle_name = val[1]

          # Call vehicle_api

          # Call current_sensor_values

        end


        # Call vehicle_api and current_sensor_values LH APIs to get data
        # Format data
      end

      private def handle_errors(error_response)
        if error_response == "vehicle_ids is invalid"
          self.errors << "Invalid vehicleIds field"
          self.error_code = :invalid_vehicleIds
        elsif error_response == "vehicle_ids is missing"
          self.errors << "VehicleIds field missing"
          self.error_code = :missing_vehicleIds
        end
      end
    end
  end
end