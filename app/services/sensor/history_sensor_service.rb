module Sensor
  class HistorySensorService
    attr_accessor :sensor_types, :supported_sensors

    def initialize(sensors)
      self.sensor_types = sensors
      self.supported_sensors = load_supported_sensors
    end

    def validate!
      return [false, "Technical issue, please try again later"] if supported_sensors.nil?

      sensor_types.each do |sensor|
        return [false, "sensor:#{sensor} not supported"] unless supported_sensors.key?(sensor)
      end
    end

    def load_supported_sensors
      YAML.load_file(Rails.root.join("config/sensors.yml"))["history_supported_sensors"]
    rescue Psych::SyntaxError, Errno::ENOENT => e
      Rails.logger.error "Unable to load or parse sensor.yml file" + e.to_s
      nil
    end

  end
end