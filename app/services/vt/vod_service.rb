module Vt
  class VodService
    include UtilHelper, ResponseHelper, VtHelper

    CREATE_QUERY_PARAMS = %i[createdAt creatorId creatorType
                            deviceId driver duration
                            endTime endTimeEpoch epoch extraData
                            format media requestType resolution
                            startDtm startTime startTimeEpoch status
                            updatedAt vehicleUuid vodId].freeze

    FETCH_QUERY_PARAMS = %i[deviceId format status creatorType requestType
                            vehicleUuid startTime endTime
                            page perPage].freeze

    attr_accessor :auth_token, :pagination, :status_code, :error_code, :errors, :request_params, :current_account, :required_params

    def initialize(request_params, current_account)
      self.request_params = request_params
      self.status_code = nil
      self.errors = []
      self.current_account = current_account
    end

    def validate!
      check_params
    end

    def fetch!
      self.required_params = %i[]
      validate!
      return if errors.present?
      if current_account.present? && current_account["account"].present? && current_account["account"]["global_account_id"].present?
        request_params[:account_uuid] = current_account["account"]["global_account_id"]
      end
      @status_code, response = video_endpoint(request_params)
      @pagination = {
        "page": response["data"]["pagination"]["page"],
        "per_page": response["data"]["pagination"]["per_page"],
        "count": response["data"]["pagination"]["total"],
        "more": !response["data"]["pagination"]["is_last_page"],
      }
      return response["data"]["values"] if status_code == "success"

      error_message = if response["data"] && response["data"]["errors"]&.first&.[]("code").present?
                        response["data"]["errors"]
                      else
                        response
                      end
      handle_errors(status_code, error_message)
    end

    def create!
      self.required_params = %i[format resolution requestType creatorType deviceId duration startTime].freeze
      validate!
      return if errors.present?
      @status_code, response = video_endpoint_v2_post(request_params)
      return response if status_code == "success"

      response["data"]["errors"].each do |error|
        handle_errors(status_code, error)
      end
    end

    private

    def handle_errors(error_code, error_message)
      case error_code
      when 400, "failed"
        self.error_code = :invalid_request
        errors << "Invalid request Error: #{error_message}"
      when /not supported/
        self.error_code = :not_supported
        errors << "Currently not supported Error: #{error_message}"
      when /Data not found/
        self.error_code = :not_found
        errors << "Data not found Error: #{error_message}"
      when 308
        self.error_code = :technical_issue
        errors << "Technical issue, please try again later"
      else
        self.error_code = :technical_issue
        errors << (error_message.presence || "Technical issue, please try again later")
      end
    end

    def check_params
      missing_params = []
      required_params.each do |param|
        missing_params << param if request_params[param].blank?
      end

      unless missing_params.empty?
        handle_errors("Data not found", "Missing parameter(s): #{missing_params.join(', ')}")
      end
    end
  end
end
