# frozen_string_literal: true

module Vehicle
  module Telematics
    class VodService
      include UtilHelper, ResponseHelper, VtHelper
      FETCH_QUERY_PARAMS = %i[device_id format status creator_type request_type
                            account_uuid vehicle_uuid start_time end_time
                            start_time_epoch end_time_epoch is_epoch
                            page_number page_size].freeze

      attr_accessor :auth_token, :pagination, :status_code, :errors, :request_params

      def initialize(request_params)
        self.request_params = request_params
        self.status_code = nil
        self.errors = []
      end

      def fetch!
        @status_code, response = video_endpoint(request_params)
        return response["data"] if response["status"]

        handle_errors(response["data"]["errors"].first["code"])
        response["data"]["errors"]
      end

      private def handle_errors(error_response)
        errors << case error_response
                  when /invalid/
                    error_response
                  when /not supported/
                    error_response
                  when "Data not found"
                    "Data not found"
                  else
                    "Technical issue, please try again later"
                  end
      end
    end
  end
end