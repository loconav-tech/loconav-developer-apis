module Throttler
  class UpdationService
    attr_accessor :params, :errors, :throttler_config

    def initialize(params)
      self.params = params
      self.errors = []
    end

    def update_config
      validate_scope_and_fetch_config
      return if errors.any?

      window = params[:window] || throttler_config.window
      limit = params[:limit] || throttler_config.limit
      api_config_map = params[:api_config] ? update_api_config : throttler_config.api_config

      return if errors.any?

      throttler_config.update(limit: limit, window: window, api_config: api_config_map)
      throttler_config
    end

    private def validate_scope_and_fetch_config
      return errors << "Invalid scope" unless params[:scope] == "global" || params[:scope] == "local"

      self.throttler_config = (params[:scope] == "global" ? fetch_global_config : fetch_user_config)
      errors << "config not found" unless throttler_config.present?
    end

    private def fetch_global_config
      ThrottlerConfig.find_by(scope: "global")
    end

    private def fetch_user_config
      return errors << "auth_token should be there if scope is local" unless params[:auth_token].present?

      ThrottlerConfig.find_by(auth_token: params[:auth_token])
    end

    private def update_api_config
      api_config_map = {}
      params[:api_config].each do |config|
        validate_api_config(config)
        api_config_map["#{config['endpoint']},#{config['method']}"] = config
      end
      api_config_map
    end

    private def validate_api_config(config)
      errors << "endpoint or method or limit or window not present in config" if config.values_at("endpoint", "method", "limit", "window").any?(&:nil?)
    end
  end
end