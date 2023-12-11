module Api
  module V1
    module Vt
      class VodController < ApplicationController
        def index
          request_params = params.permit(::Vt::VodService::FETCH_QUERY_PARAMS)
          service = ::Vt::VodService.new(request_params)
          response = service.fetch!

          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: response)
                     else
                       Loconav::Response::Builder.success(values: response, pagination: service.pagination)
                     end
          render json: response, status: service.status_code
        end

        def create
          request_params = params.permit(::Vt::VodService::CREATE_QUERY_PARAMS)
          service = ::Vt::VodService.new(request_params)
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

