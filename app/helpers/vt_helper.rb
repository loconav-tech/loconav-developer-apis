module VtHelper
  def video_endpoint(params)
    api_instance = ApolloVtClient::V1Api.new
    opts = {}
    epoch = params[:is_epoch]
    opts[:device_id] = params[:device_id]
    if params[:is_epoch]
      opts[:start_time_epoch] = params["start_time"]
      opts[:end_time_epoch] = params["end_time"]
      opts[:epoch] = params["is_epoch"]
    else
      opts[:start_time] = params["start_time"]
      opts[:end_time] = params["end_time"]
    end
    opts[:creator_type] = params["creator_type"]
    begin
      api_instance.v1_vod_list(epoch, opts)
    rescue ApolloVtClient::ApiError => e
      status e.code.to_i
      JSON.parse(e.response_body)
    end
  end

  def set_video_endpoint(params)
    api_instance = ApolloVtClient::V1Api.new
    data_object = {
      device_id: params["device_id"],
      format: params[:format],
      resolution: params[:resolution],
      duration: params[:duration],
    }
    if params[:is_epoch]
      data_object[:start_time_epoch] = params[:start_time]
      data_object[:epoch] = params[:is_epoch]
    else
      data_object["start_time"] = params[:start_time]
    end
    data = ApolloVtClient::VOD.new(data_object)
    begin
      response = api_instance.v1_vod_create(data)
    rescue ApolloVtClient::ApiError => e
      JSON.parse(e.response_body)
    end
    response
  end

  def livestream_post_endpoint(params)
    begin
      api_instance = ApolloVtClient::V1Api.new
      data = ApolloVtClient::StartLiveStream.new({ device_id: params["device_id"], resolution: params[:resolution] })
      result = api_instance.v1_livestream_create(data)
      ["success", result.response]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def livestream_put_endpoint(params)
    begin
      api_instance = ApolloVtClient::V1Api.new
      session_id = params["id"]
      data = ApolloVtClient::UpdateLiveStream.new({ resolution: params[:resolution], status: params[:status] })
      result = api_instance.v1_livestream_update(session_id, data)
      ["success", result.response]
    rescue ApolloVtClient::ApiError => e
      parsed_error = JSON.parse(e.response_body)["message"] if e.response_body.present?
      [e.code.to_i, parsed_error]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def livestream_delete_endpoint(session_id)
    begin
      api_instance = ApolloVtClient::V1Api.new
      result = api_instance.v1_livestream_delete(session_id)
      ["success", result&.response]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def livestream_get_endpoint(params)
    api_instance = ApolloVtClient::V1Api.new
    session_id = params["session_id"]
    begin
      result = api_instance.v1_livestream_read(session_id)
      ["success", result&.response]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def vt_lookup_endpoint
    api_instance = ApolloVtClient::V1Api.new
    begin
      result = api_instance.v1_lookups_list
    rescue ApolloVtClient::ApiError => e
      status e.code.to_i
      return JSON.parse(e.response_body)
    end
    result
  end
end
