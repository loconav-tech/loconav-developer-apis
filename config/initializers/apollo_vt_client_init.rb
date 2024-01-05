ApolloVtClient.configure do |config|
  config.host = "#{Rails.application.secrets.loconav_video_telematics_url}"
  config.base_path = "/api"
end
ApolloVtClient::Configuration.default.server_index = nil
