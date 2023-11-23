module Throttler
  class UpdationService
    attr_accessor :params, :errors

    def initialize(params)
      self.params = params
      self.errors = []
    end

    def update_config
      if params[:scope].present? && params[:scope] == "global"
        throttler_config = ThrottlerConfig.find_by(scope: "global")
      elsif params[:scope].present? && params[:scope] == "local"
        if params[:auth_token].present?
          throttler_config = ThrottlerConfig.find_by(auth_token: params[:auth_token])
        else
          errors << "auth_token should be there if scope is local"
          return
        end
      else
        errors << "scope is wrong or not present"
        return
      end

      if throttler_config.nil?
        errors << "config not found"
        return
      end

      window = params[:window] || throttler_config.window
      limit = params[:limit] || throttler_config.limit
      api_config_map = {}
      update_api_config(api_config_map, params[:api_config])

      if errors.any?
        return
      end

      if params[:api_config].nil?
        api_config_map = throttler_config.api_config
      end

      throttler_config.update(limit:limit, window:window, api_config: api_config_map)
      throttler_config
    end

    private def update_api_config(api_config_map, api_config)
      if api_config.present?
        api_config.each do |config|
          if config["endpoint"].nil? || config["method"].nil? || config["limit"].nil? || config["window"].nil?
            errors << "endpoint or method or limit or window not present in config"
            return
          end
          api_config_map["#{config['endpoint']},#{config['method']}"] = config
        end
      end
    end
  end
end
