module Api
  module V1
    class VehicleStatsController < ApplicationController
      include AuthenticationHelper

      before_action :authenticate_account

      def last_known
        request_params = params.permit(Vehicle::Telematics::StatsService::QUERY_PARAMS)
        pagination = build_pagination
        service = Vehicle::Telematics::StatsService.new(
          current_account["authentication_token"],
          request_params[:vehicleIds],
          request_params[:sensors],
          pagination,
        )
        stats, paginate_metadata = service.run!
        pagination.merge!(paginate_metadata) if paginate_metadata
        status_code = to_status(service)

        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                          message: service.errors.join(", "),
                                                          code: status_code,
                                                        }])
                   else
                     Loconav::Response::Builder.success(values: stats, pagination:)
                   end
        render json: response, status: status_code
      end

      private def build_pagination
        {
          page: params[:page].to_i || 1,
          per_page: params[:per_page].to_i || 10,
        }
      end

      private def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[invalid_pagination_request invalid_vehicleIds missing_vehicleIds
                                       sensor_not_supported invalid_sensors_count])
            :bad_request
          elsif service.error_code.in?(%i[technical_issue data_not_found])
            :unprocessable_entity
          end
        else
          :ok
        end
      end
    end
  end
end
