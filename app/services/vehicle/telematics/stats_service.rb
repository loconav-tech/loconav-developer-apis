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
        vehicles_map = {
          "0a216232-175a-4993-ab14-2168bc642ce0": [
            [
              88401,
              "TRANSPORTER10"
            ]
          ],
          "1aa3fcc2-3a84-4aa6-8577-f0c43bed3756": [
            [
              88398,
              "TRANSPORTER7"
            ]
          ],
          "2a4559fa-68fc-49bd-8220-b99f391ad671": [
            [
              93893,
              "TESTORG3"
            ]
          ],
          "2b418fe7-5225-453f-939b-0179a747471f": [
            [
              93892,
              "TESTORG2"
            ]
          ],
          "2bf7dd9b-db28-4485-a27f-c40fd69fcf5a": [
            [
              88390,
              "TEST_BULKUPDATE"
            ]
          ],
          "3001f8d7-06b4-4de4-8394-8a637f442ff5": [
            [
              93890,
              "TEST_ORG1"
            ]
          ],
          "40b0a5fd-4570-46c1-9eee-171db14d3c08": [
            [
              88549,
              "TEST_BULKUPDATE1"
            ]
          ],
          "5949e72e-cc9a-4399-b014-ef13bdf6bbce": [
            [
              93891,
              "TESTORG1"
            ]
          ],
          "7a1cc9bb-28c0-4f52-8b7c-c5e03071d36e": [
            [
              93894,
              "TESTORG4"
            ]
          ],
          "8b59225d-3538-4d78-af51-7bff478c50b4": [
            [
              32676,
              "DCS_VEHICLE"
            ]
          ],
          "8e457fee-69b0-423c-896d-3b1372fd8f7b": [
            [
              88399,
              "TRANSPORTER8"
            ]
          ],
          "b2c669ee-c96b-484f-8d0f-5ae877c57de8": [
            [
              55976,
              "AJDWKJWD"
            ]
          ],
          "b6047cfc-6c1b-4dfd-bcfa-4b9bf1f17d02": [
            [
              52800,
              "DEMO4086500804"
            ]
          ],
          "ddebbb67-a4a1-4d6c-bdd7-1f921db0b9ea": [
            [
              88712,
              "TROUBLESHOOT_V1"
            ]
          ],
          "def39687-982b-44e7-895e-10c83a3fb0e3": [
            [
              88976,
              "MOCKDEVICEADDON0"
            ]
          ],
          "ec3bce80-614a-4200-b092-50c539a7c315": [
            [
              28449,
              "REG1234"
            ]
          ]
        }.to_json
        fetch_last_known_stats(JSON.parse(vehicles_map))
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
