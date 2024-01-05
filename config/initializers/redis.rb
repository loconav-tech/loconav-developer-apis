require "redis"
REDIS = Redis.new(host: Rails.application.secrets.redis_host, port: 6379, db: Rails.application.secrets.redis_db_index)
