# frozen_string_literal: true

FULL_LOG_HEADERS = Rails.application.secrets.full_log_headers
FULL_LOG_RESOURCE_TYPE=Rails.application.secrets.full_log_resource_type
FULL_LOG_SOURCE=Rails.application.secrets.full_log_source

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = "ActionController::API"

  config.lograge.custom_options = lambda do |event|
    {
      host: event.payload[:host],

      process_id: Process.pid,
      request_id: event.payload[:headers]["action_dispatch.request_id"],
      LogConstants::REQUEST_START_TIME => Time.now.to_i,
      LogConstants::MESSAGE => "full_log",
      LogConstants::RESOURCE_TYPE => FULL_LOG_RESOURCE_TYPE,
      LogConstants::SOURCE => FULL_LOG_SOURCE,
      LogConstants::ELAPSED_TIME => event.duration.to_i.to_s + "ms".to_s,

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
      LogConstants::RESPONSE_PAYLOAD => controller.response.body.as_json,
      LogConstants::REQUEST_PAYLOAD => controller.request.body.read.to_s,
      LogConstants::HTTP_METHOD => controller.request.request_method.to_s,
      LogConstants::RESOURCE_URI => controller.request.fullpath.to_s,
      LogConstants::REQUEST_PARAM => controller.params.as_json,
      LogConstants::MDC_USER_ID => controller.current_account["id"].to_s,
      LogConstants::RESPONSE_CODE => controller.response.status.to_s,
      LogConstants::RESOURCE_URL => controller.request.url.to_s,

      LogConstants::HEADERS => get_desired_headers(controller),


    }
  end

  def get_desired_headers(controller)
    desired_header = {}

    FULL_LOG_HEADERS.each do |header|
      if controller.request.headers[header].present?
        desired_header[header.to_sym] = controller.request.headers[header]
      end
    end
    desired_header.as_json
  end
end