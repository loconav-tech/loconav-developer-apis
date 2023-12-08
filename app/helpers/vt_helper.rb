module VtHelper
  def video_endpoint(params)
    api_instance = ApolloVtClient::V2Api.new
    opts = {}
    opts[:account_uuid] = params[:account_uuid]
    epoch = params[:is_epoch]
    opts[:epoch] = epoch
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
      response = api_instance.v2_vod_list(opts)
      ["200", response.as_json]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)]
    end
  end

  def video_endpoint_v2_post(params)
    api_instance = ApolloVtClient::V2Api.new
    opts = {}
    epoch = params[:is_epoch]
    opts[:device_id] = params["device_id"] if params["device_id"].present?
    if params[:is_epoch]
      opts[:start_time_epoch] = params["start_time"]
      opts[:end_time_epoch] = params["end_time"] if params["end_time"].present?
      opts[:epoch] = params["is_epoch"]
    else
      opts[:start_time] = params["start_time"]
      opts[:end_time] = params["end_time"] if params["end_time"].present?
    end
    opts[:request_type] = params["request_type"]
    opts[:format] = params["format"]
    opts[:resolution] = params["resolution"]
    opts[:duration] = params["duration"] if params["duration"].present?
    opts[:creator_type] = params["creator_type"] if params["creator_type"].present?
    opts[:extra_data] = params["extra_data"] if params["extra_data"].present?
    begin
      [201, api_instance.v2_vod_create(opts, {}).as_json]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)]
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
      [e.code, JSON.parse(e.response_body)]
    end
    response
  end

  def livestream_post_endpoint(params)
    api_instance = ApolloVtClient::V1Api.new
    data = ApolloVtClient::StartLiveStream.new({ device_id: params["device_id"], resolution: params[:resolution] })
    begin
      result = api_instance.v1_livestream_create(data)
    rescue ApolloVtClient::ApiError => e
      JSON.parse(e.response_body)
    end
    result
  end

  def livestream_put_endpoint
    api_instance = ApolloVtClient::V1Api.new
    session_id = params["session_id"]
    data = ApolloVtClient::UpdateLiveStream.new({ resolution: params[:resolution], status: params[:status] })
    begin
      result = api_instance.v1_livestream_update(session_id, data)
    rescue ApolloVtClient::ApiError => e
      status e.code.to_i
      JSON.parse(e.response_body)
    end
    result
  end

  def livestream_delete_endpoint
    api_instance = ApolloVtClient::V1Api.new
    session_id = params["session_id"]
    begin
      result = api_instance.v1_livestream_delete(session_id)
    rescue ApolloVtClient::ApiError => e
      status e.code.to_i
      JSON.parse(e.response_body)
    end
    result
  end

  def livestream_get_endpoint
    api_instance = ApolloVtClient::V1Api.new
    session_id = params["session_id"]
    begin
      result = api_instance.v1_livestream_read(session_id)
    rescue ApolloVtClient::ApiError => e
      status e.code.to_i
      JSON.parse(e.response_body)
    end
    result
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
