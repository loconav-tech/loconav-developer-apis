module UtilHelper
  def get_indices(pagination)
    start_index = (pagination[:page].to_i - 1) * pagination[:per_page].to_i
    end_index = start_index + pagination[:per_page].to_i
    [start_index, end_index]
  end

  def pagination_metadata(pagination, total_count)
    {
      count: total_count,
      more: total_count > (pagination[:page].to_i * pagination[:per_page].to_i),
    }
  end

  def json_parsable?(json_string)
    JSON.parse(json_string)
    true
  rescue JSON::ParserError => e
    false
  end

  private def build_pagination(params)
    {
      page: params[:page].to_i || 1,
      per_page: params[:per_page].to_i || 10,
    }
  end
end
