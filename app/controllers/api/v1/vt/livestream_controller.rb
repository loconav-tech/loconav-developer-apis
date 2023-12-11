module Api
  module V1
    module Vt
      class LivestreamController < ApplicationController
        include AuthenticationHelper

        before_action :authenticate_account

        def index
          service = ::Vt::LivestreamService.new
          fetch_response = service.fetch_livestream(params)
          response = if service.errors.any?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: fetch_response)
                     end
          render json: response, status: status_code
        end

        def create
          service = ::Vt::LivestreamService.new
          create_response = service.create_livestream(params)
          status_code = to_status(service)

          response = if service.errors.any?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: create_response)
                     end
          render json: response, status: status_code
        end

        def update
          service = ::Vt::LivestreamService.new
          update_response = service.update_livestream(params)
          status_code = to_status(service)

          response = if service.errors.any?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: update_response)
                     end
          render json: response, status: status_code
        end

        def destroy
          service = ::Vt::LivestreamService.new
          delete_response = service.delete_livestream(params)
          status_code = to_status(service)

          response = if service.errors.any?
                       Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                     code: status_code,
                                                                   }])
                     else
                       Loconav::Response::Builder.success(values: delete_response)
                     end
          render json: response, status: status_code
        end

        private def to_status(service)
          if service.error_code
            if service.error_code.in?(%i[invalid_request])
              :bad_request
            elsif service.error_code.in?(%i[not_supported not_found technical_issue])
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
