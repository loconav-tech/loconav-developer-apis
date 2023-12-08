module Vehicle
  module Telematics
    class VodService
      include UtilHelper, ResponseHelper, VtHelper

      CREATE_QUERY_PARAMS = %i[created_at creator_id creator_type
                               device_id driver duration end_time end_time_epoch epoch extra_data
                               format media request_type resolution
                               start_dtm start_time start_time_epoch status
                               updated_at vehicle_uuid vod_id ].freeze

      attr_accessor :auth_token, :pagination, :status_code, :errors, :request_params

      def initialize(request_params)
        self.request_params = request_params
        self.status_code = nil
        self.errors = []
      end

      def create!
        @status_code, response = video_endpoint_v2_post(request_params)
        return response if response["status"]

        @pagination = nil
        response["data"]["errors"] do |error|
          handle_errors(error)
        end
        response["data"]["errors"]

      end

      private def handle_errors(error_response)
        case error_response["code"]
        when /invalid/
          errors << error_response
        when /not supported/
          errors << error_response
        when "required"
          errors << error_response
          self.error_code = :data_not_found
        else
          errors << "Technical issue, please try again later"
          self.error_code = :technical_issue
        end
      end

    end
  end
end

