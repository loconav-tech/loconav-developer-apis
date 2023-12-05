# frozen_string_literal: true

FULL_LOG_HEADERS = Rails.application.secrets.full_log_headers.split
FULL_LOG_RESOURCE_TYPE = Rails.application.secrets.full_log_resource_type
FULL_LOG_SOURCE = Rails.application.secrets.full_log_source

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = "ActionController::API"
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    {
      host: event.payload[:host],
      process_id: Process.pid,
      request_id: event.payload[:headers]["action_dispatch.request_id"],
      requestStartTime: Time.now.to_i,
      message: "full_log",
      resourceType: FULL_LOG_RESOURCE_TYPE,
      source: FULL_LOG_SOURCE,
      elapsedTime: event.duration.to_i.to_s + "ms".to_s,
      remote_ip: event.payload[:remote_ip],
      ip: event.payload[:ip],
      x_forwarded_for: event.payload[:x_forwarded_for],
      params: event.payload[:params].to_json,
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception]&.last.to_s,
      # exception_backtrace: event.payload[:exception_object]&.backtrace&.join(","),
      time: event.time,
    }
  end
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      responsePayload: controller.response.body.as_json,
      requestPayload: controller.request.body.read.to_s,
      httpMethod: controller.request.request_method.to_s,
      resourceURI: controller.request.fullpath.to_s,
      requestParam: controller.params.as_json,
      "User-Id": get_user_id(controller),
      responseCode: controller.response.status.to_s,
      resourceURL: controller.request.url.to_s,
      headers: get_desired_headers(controller),
    }
  end

  def get_user_id(controller)
    controller.current_account["id"].to_s
  rescue StandardError
    nil
  end

  def get_desired_headers(controller)
    desired_header = {}

    header = FULL_LOG_HEADERS
    if controller.request.headers[header].present?
      desired_header[header.to_sym] = controller.request.headers[header]
    end
    desired_header.as_json
  end
end
