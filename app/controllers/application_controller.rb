class ApplicationController < ActionController::API
  before_action :log_request_body
  around_action :log_response_body

  private

  def log_request_body
    request.body.rewind
    request_body = request.body.read
    request.env['action_dispatch.request.request_parameters'] = JSON.parse(request_body)
  rescue JSON::ParserError
    Rails.logger.error("Failed to parse request body: #{request_body}")
  end

  def log_response_body
    yield
  ensure
    response_body = response.body
    Rails.logger.info("Response Body: #{response_body}")
  end
end
