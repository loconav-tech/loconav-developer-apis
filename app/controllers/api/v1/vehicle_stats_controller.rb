module Api
  module V1
    class VehicleStatsController < ApplicationController
      include AuthenticationHelper, UtilHelper

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
                     Loconav::Response::Builder.success(values: stats, pagination:pagination)
                   end
        render json: response, status: status_code
      end

      private def build_pagination
        {
          page: params[:page] || 1,
          per_page: params[:per_page] || 10,
        }
      end

      def history
        request_params = params.permit(Vehicle::Telematics::HistoryStatsService::QUERY_PARAMS)
        service = Vehicle::Telematics::HistoryStatsService.new(
          current_account["authentication_token"],
          request_params[:vehicleId],
          request_params[:start_time],
          request_params[:end_time],
          request_params[:sensors],
        )
        history_stats = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: history_stats)
                   end
        render json: response, status: status_code
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
