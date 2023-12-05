module Sensor
  class SensorService
    attr_accessor :sensor_types, :sensor_type_mapping

    def initialize(sensor_types)
      self.sensor_types = sensor_types
      self.sensor_type_mapping = load_sensor_mapping
    end

    def fetch_sensors
      success, response = validate!
      return [success, response] unless success

      sensor = []
      sensor_count = {}
      sensor_types.each do |type|
        return [false, "Sensor type #{type} not supported"] unless sensor_type_mapping[type]

        get_gps_sensors(sensor) if type == "gps"

        sensor << type

        sensor_count[sensor_type_mapping[type]] = "sensor"
        return [false, "Only 3 sensors supported at a time"] if sensor_count.size > 3
      end
      [true, sensor]
    end

    private def validate!
      return [false, "Technical issue"] if sensor_type_mapping.nil?

      self.sensor_types = get_default_sensor if sensor_types.nil? || sensor_types.empty?
      # sensor_types.count > 3 ? [false, "Only 3 sensors supported at a time"] : [true, nil]
      [true, nil]
    end

    def load_sensor_mapping
      YAML.load_file(Rails.root.join("config/sensors.yml"))["sensor_types"]
    rescue Psych::SyntaxError, Errno::ENOENT => e
      Rails.logger.error "Unable to load or parse sensor.yml file" + e.to_s
      nil
    end

    def get_gps_sensors(sensor)
      get_default_sensor.each do |default_sensor|
        sensor << default_sensor
      end
    end

    def get_default_sensor
      ["speed", "ignition", "orientation", "current_location_coordinates", "gps"]
    end
  end
end
