class AddScopeToThrottlerConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :throttler_configs, :scope, :string
  end
end
