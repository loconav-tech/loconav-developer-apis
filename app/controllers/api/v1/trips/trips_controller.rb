module Api
  module V1
    module Trips

      class TripsController < ApplicationController
        include AuthenticationHelper

        before_action :authenticate_account

        def index
          request_params = params.permit(::Trips::TripService::FETCH_TRIP_PARAMS)
          service = ::Trips::TripService.new(@current_account, request_params)
          response = service.fetch_trips
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
          if service.status_code.in?(%i[ invalid_request not_found ])
            :bad_request
          elsif service.status_code.in?(%i[technical_issue data_not_found unprocessable_entity])
            :unprocessable_entity
          elsif service.status_code == "success"
            :ok
          end
        end
      end
    end
  end
end
