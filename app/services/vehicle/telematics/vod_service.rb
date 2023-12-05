module Vehicle
  module Telematics
    class VodService
      include UtilHelper, ResponseHelper

      QUERY_PARAMS = [resolution: String,
                      duration: Integer,
                      start_time: Time,
                      start_time_epoch: Integer,
                      epoch: Boolean,
                      device_id: String,
                      format: String].freeze

    end
  end
end

