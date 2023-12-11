module Vt
  class VodService
    include UtilHelper, ResponseHelper, VtHelper

    CREATE_QUERY_PARAMS = %i[created_at creator_id creator_type
                               device_id driver duration end_time end_time_epoch epoch extra_data
                               format media request_type resolution
                               start_dtm start_time start_time_epoch status
                               updated_at vehicle_uuid vod_id ].freeze

    FETCH_QUERY_PARAMS = %i[device_id format status creator_type request_type
                            account_uuid vehicle_uuid start_time end_time
                            start_time_epoch end_time_epoch is_epoch
                            page_number page_size].freeze

    attr_accessor :auth_token, :pagination, :status_code, :error_code, :errors, :request_params, :current_account

    def initialize(request_params, current_account)
      self.request_params = request_params
      self.status_code = nil
      self.errors = []
      self.current_account = current_account
    end

    def fetch!
      if current_account.present? && current_account["account"].present? && current_account["account"]["global_account_id"].present?
        request_params[:account_uuid] = current_account["account"]["global_account_id"]
      end
      @status_code, response = video_endpoint(request_params)
      return response["data"] if status_code == "success"

      error_message = if response["data"] && response["data"]["errors"]&.first["code"].present?
                        response["data"]["errors"]
                      else
                        response
                      end
      handle_errors(status_code, error_message)
    end

    def create!
      @status_code, response = video_endpoint_v2_post(request_params)
      return response if status_code == "success"

      response["data"]["errors"].each do |error|
        handle_errors(status_code, error)
      end
    end

    private def handle_errors(error_code, error_message)
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
        errors << if error_message.present?
                    error_message
                  else
                    "Technical issue, please try again later"
                  end
      end
    end
  end
end
