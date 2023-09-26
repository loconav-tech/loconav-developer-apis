module ResponseHelper
  def respond(response, klass, error_message)
    if response && response.body.present?
      response_data = JSON.parse(response.body)
      raise_error(response_data, klass) unless response.success?
      response_data
    else
      raise klass, error_message
    end
  end

  def raise_error(response_data, klcass)
    error_msg = response_data.dig("error") || response_data.dig("data", "errors", 0, "message")
    raise klcass, error_msg
  end
end
