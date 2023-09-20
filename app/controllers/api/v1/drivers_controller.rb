module Api
  module V1
    class DriversController < ApplicationController

      include AuthenticationHelper

      # GET /api/v1/drivers
      def index
        request_params = params.permit(Drivers::QueryService::QUERY_PARAMS)
        render json: Drivers::QueryService.new(current_account, request_params).run!
      end
    end
  end
end
