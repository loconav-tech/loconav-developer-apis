module Vehicle
  module Telematics
    class StatsService
      QUERY_PARAMS = [:vehicleIds => [], :sensors => []].freeze

      attr_accessor :account, :vehicles, :sensors, :error_code, :errors

      def initialize(account, vehicles, sensors, pagination)
        self.account = account
        self.pagination = pagination
        self.vehicles = vehicles
        self.sensors = sensors
        self.errors = []
      end

      def run!
        # Get all vehicles by their UUIds
        validate_data
        success, response = Linehaul::VehicleService.new(account["authentication_token"])
                                                    .fetch_vehicle_lite(vehicles, pagination)
        unless success
          handle_errors(response)
          return
        end
        # vehicles_map = response if success
        vehicles_map = { "0007d845-8bd8-4064-b4a3-9b84fc17548f" => [[90659, "VDIRECTORYTEST598"]], "0015f2fe-d8c6-48bb-bc47-b26ee1dd02bc" => [[92417, "TEST0017"]], "0022496e-4372-45e3-9a5d-de8afe1b02cb" => [[92913, "TEST0460"]], "00493792-9fd3-4eb1-9a02-004b050bc859" => [[90857, "VDIRECTORYTEST706"]], "0061261b-e5b4-46ca-b4e8-e462342a0c30" => [[93011, "TEST0515"]], "00654712-70cd-47d2-be80-422bdee2549d" => [[91932, "VDIRECTORY533"]], "006a939f-78df-4d04-982f-65695664b83f" => [[92773, "TEST0373"]], "006c0ec6-7546-481b-b828-55da74f015a1" => [[40012, "MOCKDEVICEDIV022"]], "006ec9b7-92bc-4e19-a061-082f39154414" => [[93623, "TEST0852"]], "00744358-efd6-40a4-b80b-3f2c663a7ac2" => [[90256, "VDIRECTORYTEST205"]] }
        fetch_last_known_stats(vehicles_map)
      end

      private def fetch_last_known_stats
        vehicles.each do |vehicle_uuid|
          vehicle = {
            uuid: vehicle_uuid,
            id: vehicles_map[vehicle_uuid].first&.first,
            name: vehicles_map[vehicle_uuid].first&.second,
          }
          Rails.logger.info "Fetching sensor stats for vehicle:" + vehicle.to_s
          fetch_sensor_stats(vehicle)
          # Call vehicle_api
          # Call current_sensor_values
        end
      end

      private def fetch_sensor_stats(vehicle)
        sensors.each do |sensor_type|

        end
      end

      private def validate_data

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