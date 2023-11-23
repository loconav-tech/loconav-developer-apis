module ThrottlerHelper
  extend ActiveSupport::Concern
  include ThrottlerLimitHelper

  HEADER_USER_AUTHENTICATION = Rails.application.secrets.header_user_authentication
  DEFAULT_THROTTLING_LIMIT = 20
  DEFAULT_THROTTLING_WINDOW = 60

  mattr_accessor :client_map
  self.client_map = {}

  def self.client_reload_cron
    configs = ThrottlerConfig.all
    configs.each do |config|
      if config.scope == "global"
        client_map["global api config"] = { api_config: config.api_config }
      else
        client_map[config.auth_token] = { limit: config.limit, window: config.window, api_config: config.api_config }
      end
    end
    puts client_map
  end

  def do_throttle
    key = (Digest::MD5.hexdigest request.headers[HEADER_USER_AUTHENTICATION])
    throttle_config = get_config(key)
    limit_available = rate_limit(throttle_config[:redis_key], throttle_config[:limit], throttle_config[:window])
    if limit_available <= 0
      render json: Loconav::Response::Builder.failure(errors: ["TOO MANY REQUESTS"]), status: :too_many_requests
    end
    response.headers["X-Rate-Limit-Remaining"] = limit_available.to_s
    response.headers["X-Rate-Limit-Limit"] = throttle_config[:limit].to_s
  end

  private def get_config(key)
    http_method = request.method.to_s
    endpoint = request.path
    if client_map[key].present?
      client = client_map[key]
      if client[:api_config]["#{endpoint},#{http_method}"].present?
        api_config = client[:api_config]["#{endpoint},#{http_method}"]
        limit = api_config["limit"]
        window = api_config["window"]
        redis_key = "#{key}#{endpoint}"
      else
        limit = client[:limit]
        window = client[:window]
        redis_key = key
      end
    elsif client_map["global api config"].present? && client_map["global api config"][:api_config]["#{endpoint},#{http_method}"].present?
      api_config = client_map["global api config"][:api_config]["#{endpoint},#{http_method}"]
      limit = api_config["limit"]
      window = api_config["window"]
      redis_key = "#{http_method}#{endpoint}"
    else
      limit = DEFAULT_THROTTLING_LIMIT
      window = DEFAULT_THROTTLING_WINDOW
      redis_key = key
    end
    {
      limit: limit,
      window: window,
      redis_key: redis_key,
    }
  end
end
