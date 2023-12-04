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

  def raise_error(response_data, klass)
    error_msg = response_data.dig("error") || response_data.dig("data", "errors", 0, "message")
    raise klass, error_msg
  end

  private def format_data(stat)
    {
      "display_name": stat["display_name"],
      "description": stat["description"],
      "unit": stat["unit"],
      "value": stat["value"],
      "timestamp": stat["timestamp"],
    }.delete_if {|key, value| (value.nil? || value == "N/A" || value == "") }
  end
end
