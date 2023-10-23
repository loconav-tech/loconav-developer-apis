module Sensor
  class SensorService
    attr_accessor :sensor_types, :sensor_type_mapping

    def initialize(sensor_types)
      self.sensor_types = sensor_types
      self.sensor_type_mapping = load_sensor_mapping
    end

    def fetch_sensors
      return [false, "Technical issue"] if sensor_type_mapping.nil?
      self.sensor_types = get_default_sensor if self.sensor_types.empty?
      sensor = Hash.new { |hash, key| hash[key] = [] }
      self.sensor_types.each do |type|
        sensor[sensor_type_mapping[type]] << type
      end
      [true, sensor]
    end

    def load_sensor_mapping
      YAML.load_file(Rails.root.join("config/sensors.yml"))["sensor_types"]
    rescue Psych::SyntaxError, Errno::ENOENT => e
      Rails.logger.error "Unable to load or parse sensor.yml file" + e.to_s
      return nil
    end

    def get_default_sensor
      ["gps"]
    end
  end
end
