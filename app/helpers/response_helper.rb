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

  private def validate_stats_response(stat)
    if stat["value"].nil? || stat["value"] == "N/A" || stat["value"] == ""
      return false
    end
    true
  end

  private def format_stats_response(stat)
    {
      "display_name": stat["display_name"],
      "description": stat["description"],
      "unit": stat["unit"],
      "value": stat["value"],
      "timestamp": stat["timestamp"],
    }.delete_if { |_key, value| value.nil? || value == "N/A" || value == "" }
  end
end
