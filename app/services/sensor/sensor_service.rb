module Sensor
  class SensorService
    attr_accessor :sensor_types, :sensor_type_mapping

    def initialize(sensor_types)
      self.sensor_types = sensor_types
      self.sensor_type_mapping = load_sensor_mapping
    end

    def fetch_sensors
      sensor = {}
      sensor_types.each do |type|
        sensor_klass = sensor_type_mapping[type]
        unless sensor[sensor_klass]
          sensor[sensor_klass] = []
        end
        sensor[sensor_klass] << type
      end
      sensor
    end

    def load_sensor_mapping
      YAML.load_file(mapping_file = Rails.root.join("config/sensors.yml"))["sensor_types"]
    end
  end
end
