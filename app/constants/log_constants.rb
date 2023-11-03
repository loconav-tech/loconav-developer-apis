# frozen_string_literal: true

module LogConstants
  CLIENT_IP = "clientIp".to_sym.freeze
  ELAPSED_TIME = "elapsedTime".to_sym.freeze
  HEADERS = "headers".to_sym.freeze
  HTTP_METHOD = "httpMethod".to_sym.freeze
  MDC_USER_ID = "User-Id".freeze
  MESSAGE = "log_message".to_sym.freeze
  REQUEST_PARAM = "requestParam".to_sym.freeze
  REQUEST_PATH = "requestPath".to_sym.freeze
  REQUEST_PAYLOAD = "requestPayload".to_sym.freeze
  REQUEST_START_TIME = "requestStartTime".to_sym.freeze
  RESOURCE_TYPE = "resourceType".to_sym.freeze
  RESOURCE_URI = "resourceURI".to_sym.freeze
  RESOURCE_URL = "resourceURL".to_sym.freeze
  RESPONSE_CODE = "responseCode".to_sym.freeze
  RESPONSE_PAYLOAD = "responsePayload".to_sym.freeze
  SOURCE = "source".to_sym.freeze
  TIMESTAMP = "@timestamp".to_sym.freeze
end
