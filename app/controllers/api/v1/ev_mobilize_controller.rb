module Api
  module V1
    class EvMobilizeController < ApplicationController
      include AuthenticationHelper, UtilHelper

      before_action :authenticate_account

      def create
        request_params = params.permit(Mobilization::CreationService::QUERY_PARAMS)
        service = Mobilization::CreationService.new(request_params, current_account)
        mobilize = service.run!
        status_code = to_status(service)
        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: mobilize)
                   end
        render json: response, status: status_code
      end

      def to_status(service)
        if service.error_code
          if service.error_code.in?(%i[parameter_is_wrong_or_missing])
            :bad_request
          elsif service.error_code.in?(%i[invalid_data technical_issue])
            :unprocessable_entity
          elsif service.error_code.in?(%i[data_not_found])
            :not_found
          end
        else
          :ok
        end
      end

    end
  end
end
