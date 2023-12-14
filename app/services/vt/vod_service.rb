module Vt
  class VodService
    include UtilHelper, ResponseHelper, VtHelper

    CREATE_QUERY_PARAMS = %i[createdAt creatorId creatorType
                            deviceId driver duration
                            endTime endTimeEpoch epoch extraData:{}
                            format media requestType resolution
                            startDtm startTime startTimeEpoch status
                            updatedAt vehicleUuid vodId] + [extraData: {}, media: {}]

    FETCH_QUERY_PARAMS = %i[deviceId format status creatorType requestType
                            vehicleUuid startTime endTime
                            page perPage].freeze

    attr_accessor :auth_token, :pagination, :status_code, :errors, :request_params, :current_account, :required_params

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
      handle_errors("400", "Invalid page request") unless request_params["page"].to_i > 0
      handle_errors("400", "Invalid page request") unless request_params["perPage"].to_i > 0
      return if errors.present?
      if current_account.present? && current_account["account"].present? && current_account["account"]["global_account_id"].present?
        request_params[:account_uuid] = current_account["account"]["global_account_id"]
      end
      @status_code, response = video_endpoint(request_params)
      if status_code == "success"
        @pagination = {
          "page": response["data"]["pagination"]["page"],
          "per_page": response["data"]["pagination"]["per_page"],
          "count": response["data"]["pagination"]["total"],
          "more": !response["data"]["pagination"]["is_last_page"],
        }
        return response["data"]["values"]
      else
        if response["data"] && response["data"]["errors"]&.first&.[]("code").present?
          response["data"]["errors"].each do |error|
            handle_errors(status_code, error)
          end
        else
          response
        end
      end
    end

    def create!
      self.required_params = %i[format resolution requestType creatorType deviceId duration startTime ].freeze
      validate!
      return if errors.present?

      @status_code, response = video_endpoint_v2_post(request_params)
      return response["data"] if status_code == "success"

      if response["data"].present? && response["data"]["errors"].present?
        response["data"]["errors"].each do |error|
          handle_errors(status_code, error)
        end
      else
        handle_errors(status_code, response)
      end
    end

    private

    def handle_errors(error_code, error_message)
      case error_code
      when 400, "failed"
        errors << if error_message["message"].present? && error_message["field"].present?
                    error_message["field"] + " " + error_message["message"]
                  else
                    "Invalid request Error: #{error_message}"
                  end
        self.status_code = :invalid_request
      when /not supported/
        self.status_code = :not_supported
        errors << "Currently not supported Error: #{error_message}"
      when /Data not found/
        self.status_code = :not_found
        errors << "Data not found Error: #{error_message}"
      when 308
        self.status_code = :technical_issue
        errors << "Technical issue, please try again later"
      else
        self.status_code = :unprocessable_entity
        errors << (error_message.presence || "Unable to process request")
      end
    end

    def check_params
      missing_params = []
      required_params.each do |param|
        missing_params << param if request_params[param].blank?
      end

      unless missing_params.empty?
        self.status_code = "Data not found"
        handle_errors("Data not found", "Missing parameter(s): #{missing_params.join(', ')}")
      end
    end
  end
end
