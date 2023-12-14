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
          status_code = to_status(service)
          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: response, pagination: service.pagination)
                     end
          render json: response, status: status_code
        end

        def create
          request_params = params.permit(::Vt::VodService::CREATE_QUERY_PARAMS)
          service = ::Vt::VodService.new(request_params, @current_account)
          response = service.create!
          status_code = to_status(service)
          response = if service.errors.present?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: response)
                     end
          render json: response, status: status_code
        end

        private def to_status(service)
          if service.status_code
            if service.error_code.in?(%i[ invalid_request not_found ])
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
end

