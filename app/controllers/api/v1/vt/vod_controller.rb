module Api
  module V1
    module Vt
      class VodController < ApplicationController
        include AuthenticationHelper

        before_action :authenticate_account

        def index
          request_params = params.permit(::Vt::VodService::FETCH_QUERY_PARAMS)
          service = ::Vt::VodService.new(request_params, @current_account)
          response = service.fetch!

          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: service.status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: response, pagination: service.pagination)
                     end
          render json: response, status: service.status_code
        end

        def create
          request_params = params.permit(::Vt::VodService::CREATE_QUERY_PARAMS)
          service = ::Vt::VodService.new(request_params, @current_account)
          response = service.create!
          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: service.status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: response)
                     end
          render json: response, status: service.status_code
        end
      end
    end
  end
end

