class CreateThrottlerConfig < ActiveRecord::Migration[7.0]
  def change
    create_table :throttler_configs do |t|
      t.bigint :client_id
      t.string :client_type
      t.string :auth_token
      t.bigint :limit
      t.bigint :window
      t.jsonb :api_config
      t.string :scope
      t.timestamps
    end
  end
end
