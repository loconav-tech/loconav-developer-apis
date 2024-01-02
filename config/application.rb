require_relative "boot"

require "action_controller/railtie"
require "rails/all"
require_relative '../app/middleware/prefix_truncation'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LoconavDeveloperApis
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = "Kolkata"
    config.exceptions_app = self.routes
    config.api_only = true
    config.autoload_paths << Rails.root.join('app/middleware')
    config.middleware.insert_before(ActionDispatch::Executor, ::PrefixTruncation, prefix: '/integration')
  end
end
