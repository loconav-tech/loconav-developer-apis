class ThrottlerConfig < ApplicationRecord
  include ThrottlerHelper

  enum scope: { local: "local", global: "global" }

  validates :scope, presence: true, on: :create
  validates :auth_token, uniqueness: true, if: -> { scope == "local" }, on: :create
  validates :client_id, :client_type, :auth_token, :limit, :window, presence: true, if: -> {
                                                                                          scope == "local"
                                                                                        }, on: :create
  validate :api_configs, on: :create

  after_commit :load_client_map

  private def api_configs
    api_config_map = {}
    if api_config.present?
      api_config.each do |config|
        if config["endpoint"].nil? || config["method"].nil? || config["limit"].nil? || config["window"].nil?
          errors.add(:base, "endpoint or method or limit or window not present in config")
          return
        end
        api_config_map["#{config['endpoint']},#{config['method']}"] = config
      end
    end
    self.api_config = api_config_map
  end

  def load_client_map
    ThrottlerHelper.client_reload_cron
  end
end
