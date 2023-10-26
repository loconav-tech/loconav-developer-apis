class ApplicationController < ActionController::API
  before_action :log_request_body
  around_action :log_response_body

  private

  def full_log
    log = {}
    log["message"]="full_log"
    log["http_method"] = request.request_method.to_s
    log["authorization"] = request.authorization.to_s
    log["headers"] = request.headers.env.select{|k, _| k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/}
    log["resource_uri"] = request.fullpath.to_s
    log["params"] = params.to_s
    # log.push(request.headers.to_json)
    log["resource_url"] = request.url.to_s
    log["response_code"] = response.status.to_s
    if response.body.present?
      log["response_payload"] = response.body.to_s
    end
    if request.body.nil?
      log["request_payload"] = request.body.to_s
    end
    Rails.logger.info(" full_log #{log}")
  end

  def log_request_body
    request.body.rewind
    request_body = request.body.read
    request.env['action_dispatch.request.request_parameters'] = JSON.parse(request_body)
  rescue JSON::ParserError
    Rails.logger.error("Failed to parse request body: #{request_body}")
  end

  # extend log-core library
  # put everything  rails logger
  def log_response_body
    yield
  ensure
    response_body = response.body
    append_info_to_payload(request)
    Rails.logger.info("Response Body: #{response_body}")
    full_log
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:response_body] = response.body
    payload[:request_body] = request.body.read
  end
end
