module Api
  module V1
    class ThrottlerController < ApplicationController
      def create
        service = Throttler::CreationService.new(params)
        response = service.create_client

        if service.error.present?
          render json: Loconav::Response::Builder.failure(errors: [{ message: service.error }]),
                 status: :unprocessable_entity
        else
          render json: Loconav::Response::Builder.success(values: response), status: :created
        end
      end

      def update
        params.require(:scope)
        service = Throttler::UpdationService.new(params)
        response = service.update_config

        if service.errors.any?
          render json: Loconav::Response::Builder.failure(errors: [{
                                                                     message: service.errors.join(", "),
                                                                   }]), status: :unprocessable_entity
        else
          render json: Loconav::Response::Builder.success(values: response), status: :ok
        end
      end

      def index
        service = Throttler::QueryService.new(params)
        response = service.get_all_clients

        render json: Loconav::Response::Builder.success(values: response), status: :ok
      end

      def get_by_auth_token
        service = Throttler::QueryService.new(params)
        response = service.get_client_by_token

        if response.nil?
          render json: Loconav::Response::Builder.failure(errors: [{ message: "config not present with the specified token" }]),
                 status: :unprocessable_entity
        else
          render json: Loconav::Response::Builder.success(values: response), status: :ok
        end
      end
    end
  end
end
