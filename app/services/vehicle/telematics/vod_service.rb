# frozen_string_literal: true

module Vehicle
  module Telematics
    class VodService
      include UtilHelper, ResponseHelper, VtHelper
      QUERY_PARAMS = [:device_id, :format, :status, :creator_type, :request_type,
                      :account_uuid,
                      :vehicle_uuid,
                      :start_time,
                      :end_time,
                      :start_time_epoch,
                      :end_time_epoch,
                      :is_epoch,
                      :page_number,
                      :page_size].freeze

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
        case error_response
        when /invalid/
          errors << error_response
        when /not supported/
          errors << error_response
        when "Data not found"
          errors << "Data not found"
          self.error_code = :data_not_found
        else
          errors << "Technical issue, please try again later"
          self.error_code = :technical_issue
        end
      end
    end
  end
end