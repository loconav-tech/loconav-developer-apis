module Throttler
  class QueryService
    attr_accessor :params

    def initialize(params)
      self.params = params
    end

    def get_all_clients
      page = params[:page].present? ? params[:page].to_i : 1
      per_page = params[:per_page].present? ? params[:per_page].to_i : 10
      @configs = ThrottlerConfig.limit(per_page).offset((page - 1) * per_page)
      total_count = ThrottlerConfig.count
      {
        throttler_configs: @configs,
        pagination: {
          current_page: page,
          total_pages: (total_count / per_page.to_f).ceil,
          total_count: total_count,
          more: (page * per_page) < total_count,
        }
      }
    end

    def get_client_by_token
      ThrottlerConfig.find_by(auth_token: params[:auth_token])
    end

  end
end