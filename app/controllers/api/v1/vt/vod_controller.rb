module Api
  module V1
    module Vt
      class VodController < ApplicationController
        def index; end

        def create
          request_params = params.permit(Vehicle::Telematics::VodService::CREATE_QUERY_PARAMS)
          service = Vehicle::Telematics::VodService.new(request_params)
          response = service.create!
          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: response)
                     else
                       Loconav::Response::Builder.success(values: response, pagination: service.pagination)
                     end
          render json: response, status: service.status_code
        end
      end
    end
  end
end

