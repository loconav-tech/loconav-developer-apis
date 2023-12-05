module ThrottlerHelper
  extend ActiveSupport::Concern
  include ThrottlerLimitHelper

  HEADER_USER_AUTHENTICATION = Rails.application.secrets.header_user_authentication
  DEFAULT_THROTTLING_LIMIT = 20
  DEFAULT_THROTTLING_WINDOW = 60

  mattr_accessor :client_map
  self.client_map = {}

  def self.reload_clients
    configs = ThrottlerConfig.all
    configs.each do |config|
      if config.scope == "global"
        client_map["global_api_config"] = { api_config: config.api_config }
      else
        client_map[config.auth_token] = { limit: config.limit, window: config.window, api_config: config.api_config }
      end
    end
  end

  def do_throttle
    key = (Digest::MD5.hexdigest request.headers[HEADER_USER_AUTHENTICATION])
    throttle_config = get_config(key)
    limit_available = rate_limit(throttle_config[:redis_key], throttle_config[:limit], throttle_config[:window])
    if limit_available <= 0
      render json: Loconav::Response::Builder.failure(errors: ["TOO MANY REQUESTS"]), status: :too_many_requests
    end
    set_throttler_headers(throttle_config, limit_available)
  end

  private def set_throttler_headers(throttle_config, limit_available)
    response.headers["X-Rate-Limit-Remaining"] = limit_available.to_s
    response.headers["X-Rate-Limit-Limit"] = throttle_config[:limit].to_s
  end

  private def get_config(key)
    http_method = request.method.to_s
    endpoint = request.path
    client = client_map[key] || client_map["global_api_config"]
    api_config = client&.dig(:api_config, "#{endpoint},#{http_method}")

    limit = api_config&.fetch("limit") || (client&.fetch(:limit) || DEFAULT_THROTTLING_LIMIT)
    window = api_config&.fetch("window") || (client&.fetch(:window) || DEFAULT_THROTTLING_WINDOW)
    redis_key = api_config ? "#{key}#{endpoint}" : key

    { limit:, window:, redis_key: }
  end
end
