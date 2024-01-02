class PrefixTruncation
  def initialize(app, options = {})
    @app = app
    @prefix = options[:prefix] || '/integration'
  end

  def call(env)
    env['PATH_INFO'].sub!(/^#{@prefix}/, '')
    @app.call(env)
  end
end
