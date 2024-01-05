module Api
  module V1
    class VehiclesController < ApplicationController
      include AuthenticationHelper,UtilHelper

      before_action :authenticate_account

      def index
        request_params = params.permit(Vehicle::QueryService::QUERY_PARAMS)
        pagination = build_pagination
        service = Vehicle::QueryService.new(current_account,request_params[:vehicle_number],pagination)
        vehicles = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: vehicles)
                   end
        render json: response, status: status_code
      end

      private def build_pagination
        {
          page: params[:page] || 1,
          per_page: params[:per_page] || 10,
        }
      end

      private def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[error_while_getting_response])
            :not_found
          end
        else
          :ok
        end
      end

    end
  end
end
