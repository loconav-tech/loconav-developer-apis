# frozen_string_literal: true
module Vehicle
  module Telematics
    class VtDataService

      include UtilHelper, ResponseHelper, VtHelper

      attr_accessor :auth_token, :pagination, :vehicles, :error_code, :errors

      def initialize(auth_token)
        self.auth_token = auth_token
        self.errors = []
      end

      def run!
        vt_lookup_endpoint
      end

      private def handle_errors(error_response)
        case error_response
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