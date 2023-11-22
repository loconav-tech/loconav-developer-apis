module Api
  module V1
    class ThrottlerController < ApplicationController
      def create
        @record = ThrottlerConfig.new(
          client_id: params[:client_id],
          client_type: params[:client_type],
          auth_token: params[:auth_token],
          limit: params[:limit],
          window: params[:window],
          api_config: params[:api_config],
          scope: params[:scope],)
        if @record.save
          render json: Loconav::Response::Builder.success(values:@record), status: :created
        else
          render json: Loconav::Response::Builder.failure(errors: [{ message: @record.errors.full_messages }]), status: :unprocessable_entity
        end
      end

      def update
        service = Throttler::ThrottlerService.new(params)
        response = service.update_config

        if service.errors.any?
          render json: Loconav::Response::Builder.failure(errors: [{
                                                        message: service.errors.join(", "),
                                                      }]), status: :unprocessable_entity
        else
          render json: Loconav::Response::Builder.success(values:response), status: :ok
        end

      end

      def index
        page = params[:page].present? ? params[:page].to_i : 1
        per_page = params[:per_page].present? ? params[:per_page].to_i : 10

        @configs = ThrottlerConfig.limit(per_page).offset((page - 1) * per_page)
        total_count = ThrottlerConfig.count

        render json: Loconav::Response::Builder.success(values: {
          throttler_configs: @configs,
          pagination: {
            current_page: page,
            total_pages: (total_count / per_page.to_f).ceil,
            total_count: total_count,
            has_next_page: (page * per_page) < total_count
          }
        }), status: :ok
      end

      def get_by_auth_token
        auth_token = params[:auth_token]
        client_response = ThrottlerConfig.find_by(auth_token:auth_token)
        if client_response.nil?
          render json: Loconav::Response::Builder.failure(errors: [{ message: "config not present with the specified token" }]), status: :unprocessable_entity
        else
          render json: Loconav::Response::Builder.success(values:client_response), status: :ok
        end
      end

    end
  end
end