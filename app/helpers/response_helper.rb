module ResponseHelper

  def respond(response)
    if response && response.body.present?
      response_data = JSON.parse(response.body)
      raise_error(response_data) unless response.success?
      response_data
    else
      raise StandardError, DEFAULT_ERROR_MSG
    end
  end

  def raise_error(response_data)
    error_msg = response_data.dig("error") || response_data.dig("data", "errors", 0, "message")
    raise StandardError, error_msg
  end
end