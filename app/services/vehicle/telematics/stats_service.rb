module Vehicle
  module Telematics
    class StatsService
      QUERY_PARAMS = [vehicleIds: [], sensors: []].freeze

      attr_accessor :auth_token, :pagination, :vehicles, :sensors, :error_code, :errors

      def initialize(auth_token, vehicles, sensors, pagination)
        self.auth_token = auth_token
        self.pagination = pagination
        self.vehicles = vehicles
        self.sensors = sensors
        self.errors = []
      end

      def run!
        # success, response = Linehaul::VehicleService.new(auth_token).
        #   fetch_vehicle_lite(vehicles, pagination)
        # unless success
        #   handle_errors(response)
        #   return
        # end

        # vehicles_map = response if success
        vehicles_map = { "0007d845-8bd8-4064-b4a3-9b84fc17548f" => [[90659, "VDIRECTORYTEST598"]],
                         "0015f2fe-d8c6-48bb-bc47-b26ee1dd02bc" => [[92417, "TEST0017"]], "0022496e-4372-45e3-9a5d-de8afe1b02cb" => [[92913, "TEST0460"]], "00493792-9fd3-4eb1-9a02-004b050bc859" => [[90857, "VDIRECTORYTEST706"]], "0061261b-e5b4-46ca-b4e8-e462342a0c30" => [[93011, "TEST0515"]], "00654712-70cd-47d2-be80-422bdee2549d" => [[91932, "VDIRECTORY533"]], "006a939f-78df-4d04-982f-65695664b83f" => [[92773, "TEST0373"]], "006c0ec6-7546-481b-b828-55da74f015a1" => [[40012, "MOCKDEVICEDIV022"]], "006ec9b7-92bc-4e19-a061-082f39154414" => [[93623, "TEST0852"]], "00744358-efd6-40a4-b80b-3f2c663a7ac2" => [[90256, "VDIRECTORYTEST205"]] }
        fetch_last_known_stats(vehicles_map)
      end

      private def fetch_last_known_stats(vehicles_map)
        avail_sensors = Sensor::SensorService.new(sensors).fetch_sensors
        vehicles.map do |vehicle_uuid|
          vehicle = {
            uuid: vehicle_uuid,
            id: vehicles_map[vehicle_uuid].first&.first,
            name: vehicles_map[vehicle_uuid].first&.second,
          }
          fetch_stats(vehicle, avail_sensors)
        end
      end

      private def fetch_stats(vehicle, avail_sensors)
        stats = {
          vehicle_number: vehicle[:name],
          vehicle_id: vehicle[:uuid],
        }
        avail_sensors.each do |klass, types|
          begin
            sensor_klass = "Sensor::#{klass}".constantize
            success, sensor_stats = sensor_klass.new(vehicle, auth_token, types).last_known_stats
            stats.merge!(sensor_stats) if success
          rescue NameError => e
            Rails.logger.error e
          end
        end
        stats
      end

      private def handle_errors(error_response)
        if error_response == "vehicle_ids is invalid"
          errors << "Invalid vehicleIds field"
          self.error_code = :invalid_vehicleIds
        elsif error_response == "vehicle_ids is missing"
          errors << "VehicleIds field missing"
          self.error_code = :missing_vehicleIds
        end
      end
    end
  end
end
