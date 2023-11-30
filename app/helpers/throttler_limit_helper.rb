module ThrottlerLimitHelper
  def rate_limit(key, limit, window)
    time = (Time.now.to_f * 1000).to_i
    lua_script = <<~LUA
      local pgname = KEYS[1]
      local now = ARGV[1]
      local limit = tonumber(ARGV[2])
      local window = tonumber(ARGV[3])
      local clearBefore = now - window
      local expire_time = window/1000
      redis.call('ZREMRANGEBYSCORE', pgname, 0, clearBefore)
      local already_sent = redis.call('ZCARD', pgname)
      if already_sent < limit then
        redis.call('ZADD', pgname, now, now)
      end
      redis.call('EXPIRE', pgname, expire_time)
      return limit - already_sent
    LUA
    REDIS.eval(lua_script, keys: [key], argv: [time, limit, window * 1000])
  end
end
