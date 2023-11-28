class ThrottlerConfig < ApplicationRecord
  include ThrottlerHelper

  enum scope: { local: "local", global: "global" }

  validates :scope, presence: true, on: :create
  validates :auth_token, uniqueness: true, if: -> { scope == "local" }, on: :create
  validates :client_id, :client_type, :auth_token, :limit, :window, presence: true, if: -> {
                                                                                          scope == "local"
                                                                                        }, on: :create
  before_create :update_api_config

  after_commit :load_client_map

  private def update_api_config
    api_config_map = {}
    if api_config.present?
      api_config.each do |config|
        validate_config(config)
        api_config_map["#{config['endpoint']},#{config['method']}"] = config
      end
    end
    self.api_config = api_config_map
  end

  private def validate_config(config)
    if config.values_at("endpoint", "method", "limit", "window").any?(&:nil?)
      errors.add(:base, "endpoint or method or limit or window not present in config")
      throw(:abort)
    end
  end

  def load_client_map
    ThrottlerHelper.client_reload_cron
  end
end
