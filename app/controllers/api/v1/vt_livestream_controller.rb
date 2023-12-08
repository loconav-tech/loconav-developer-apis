module Api
  module V1
    class VtLivestreamController < ApplicationController
      include AuthenticationHelper

      before_action :authenticate_account

      def index; end

      def create
        service = Vt::VtLivestreamService.new
        live_stream_response = service.create_livestream(params)
        status_code = to_status(service)

        response = if service.errors.any?
                     Loconav::Response::Builder.failure(errors: [{
                                                                   message: service.errors.join(", "),
                                                                   code: status_code,
                                                                 }])
                   else
                     Loconav::Response::Builder.success(values: live_stream_response)
                   end
        render json: response, status: status_code
      end

      def update
        service = Vt::VtLivestreamService.new
      end

      def destroy
        service = Vt::VtLivestreamService.new
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
