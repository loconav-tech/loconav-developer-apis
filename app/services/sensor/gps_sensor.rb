module Sensor
  class GpsSensor
    include ResponseHelper
    attr_accessor :types, :vehicle, :auth_token, :error_code, :errors

    def initialize(vehicle, _types)
      self.vehicle = vehicle
    end

    def format_gps_stats
      gps_stats = {}
      gps_stats.merge!({ speed: format_stats_response(vehicle["speed"]) }) if vehicle["speed"].present?
      gps_stats.merge!({ ignition: format_stats_response(vehicle["ignition"]) }) if vehicle["ignition"].present?
      gps_stats.merge!({ orientation: format_stats_response(vehicle["orientation"]) }) if vehicle["orientation"].present?
      gps_stats.merge!({current_location_coordinates: fetch_current_coordinates}) if vehicle["current_location_coordinates"].present?
      gps_stats
    end

    private def fetch_current_coordinates
      coordinate_stat = {}
      coordinate_stat.merge!({
                               lat: {
                                 "display_name": "Current latitude coordinate",
                                 "description": "It shows the current latitude coordinate of the vehicle",
                                 "unit": "degrees",
                                 "value": vehicle["current_location_coordinates"]["value"].first,
                                 "timestamp": vehicle["current_location_coordinates"]["timestamp"],
                               }
                             })
      coordinate_stat.merge!({
                               long: {
                                 "display_name": "Current longitude coordinate",
                                 "description": "It shows the current longitude coordinate of the vehicle",
                                 "unit": "degrees",
                                 "value": vehicle["current_location_coordinates"]["value"].second,
                                 "timestamp": vehicle["current_location_coordinates"]["timestamp"],
                               }
                             })
      coordinate_stat
    end
  end
end
