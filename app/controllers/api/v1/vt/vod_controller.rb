module Api
  module V1
    module Vt
      class VodController < ApplicationController
        def index
          request_params = params.permit(Vehicle::Telematics::VodService::QUERY_PARAMS)
          service = Vehicle::Telematics::VodService.new(request_params)
          response = service.fetch!

          response = if service.errors.any?
                       Loconav::Response::Builder.failure(errors: response)
                     else
                       Loconav::Response::Builder.success(values: response, pagination: service.pagination)
                     end
          render json: response, status: service.status_code
        end

        def create; end

      end
    end
  end
end
