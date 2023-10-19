module Api
  module V1
    class VehicleStatsController < ApplicationController
      include AuthenticationHelper

      before_action :authenticate_account

      def last_known
        request_params = params.permit(Vehicle::Telematics::StatsService::QUERY_PARAMS)
        pagination = {
          page: params[:page] || 1,
          per_page: params[:per_page] || 10,
        }
        service = Vehicle::Telematics::StatsService.new(
          current_account,
          request_params[:vehicleIds],
          request_params[:sensors],
          pagination)
        last_known_stats = service.run!
        status_code = to_status(service)

        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: drivers)
                   end
        render json: response, status: status_code
      end

      private def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[invalid_vehicleIds missing_vehicleIds])
            :bad_request
          end
        else
          :ok
        end
      end
    end
  end
end
