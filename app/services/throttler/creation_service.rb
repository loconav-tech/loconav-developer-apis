module Throttler
  class CreationService
    attr_accessor :params, :error

    def initialize(params)
      self.params = params
    end

    def create_client
      record = ThrottlerConfig.new(
        client_id: params[:client_id],
        client_type: params[:client_type],
        auth_token: params[:auth_token],
        limit: params[:limit],
        window: params[:window],
        api_config: params[:api_config],
        scope: params[:scope],
      )
      if record.save
        record
      else
        self.error = record.errors.full_messages
      end
    end

  end
end