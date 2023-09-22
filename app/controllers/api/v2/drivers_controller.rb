module Api
  module V2
    class DriversController < ApplicationController

      include AuthenticationHelper

      before_action :authenticate_account
      
      def index
        request_params = params.permit(Drivers::QueryService::QUERY_PARAMS)
        service = Drivers::QueryService.new(current_account, request_params)
        drivers = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: drivers)
                   end
        render json: response, status: status_code
      end

      private def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[driver_not_found])
            :not_found
          end
        else
          :ok
        end
      end
    end
  end
end
