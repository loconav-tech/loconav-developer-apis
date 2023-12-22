module Api
  module V1
    class PolygonsController < ApplicationController
      include AuthenticationHelper, UtilHelper

      before_action :authenticate_account

      def index
        pagination = build_pagination
        service = Polygon::QueryService.new(current_account,pagination,params)
        polygons = service.run!
        status_code = to_status(service)

        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: polygons["data"], pagination: polygons["pagination"])
                   end
        byebug
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
          if service.error_code.in?(%i[invalid_pagination_request active_should_be_boolean_type])
            :bad_request
          elsif service.error_code.in?(%i[technical_issue])
            :unprocessable_entity
          end
        else
          :ok
        end
      end

    end
  end
end