class SensorService
  def initialize
    @sensor_type_mapping = load_sensor_mapping
  end

  def create_sensor(sensor_type)
    sensor_klass = @sensor_type_mapping[sensor_type]
    Object.const_get(sensor_klass).new
  end

  def load_sensor_mapping
    YAML.load_file(mapping_file = Rails.root.join('config', 'sensors.yml'))
  end
end