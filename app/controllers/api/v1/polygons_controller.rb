module Api
  module V1
    class PolygonsController < ApplicationController
      include AuthenticationHelper, UtilHelper

      before_action :authenticate_account

      def index
        pagination = build_pagination
        service = Polygon::QueryService.new(current_account, pagination, params)
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
        render json: response, status: status_code
      end

      def create
        request_params = params.require("polygon").permit(Polygon::CreationService::QUERY_PARAMS)
        service = Polygon::CreationService.new(current_account, request_params)
        polygon = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: polygon)
                   end
        render json: response, status: status_code
      end

      def update
        request_params = params.require("polygon").permit(Polygon::UpdationService::QUERY_PARAMS)
        polygon_id = params[:id]
        service = Polygon::UpdationService.new(current_account, polygon_id, request_params)
        polygon = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: polygon)
                   end
        render json: response, status: status_code
      end

      private def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[invalid_pagination_request active_should_be_boolean_type parameter_is_missing parameter_is_invalid])
            :bad_request
          elsif service.error_code.in?(%i[technical_issue something_went_wrong])
            :unprocessable_entity
          end
        else
          :ok
        end
      end

    end
  end
end
