module VtHelper
  def video_endpoint(params)
    begin
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
      response = api_instance.v2_vod_list(opts)
      ["200", response.as_json]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def video_endpoint_v2_post(params)
    begin
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
      [201, api_instance.v2_vod_create(opts, {}).as_json]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def set_video_endpoint(params)
    begin
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
      api_instance.v1_vod_create(data)
      ["success", result.response]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
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
    begin
      api_instance = ApolloVtClient::V1Api.new
      session_id = params["session_id"]
      result = api_instance.v1_livestream_read(session_id)
      ["success", result&.response]
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end

  def vt_lookups
    begin
      api_instance = ApolloVtClient::V1Api.new
      api_instance.v1_lookups_list
    rescue ApolloVtClient::ApiError => e
      [e.code.to_i, JSON.parse(e.response_body)["message"]]
    rescue StandardError => e
      ["failed", e.message]
    end
  end
end
