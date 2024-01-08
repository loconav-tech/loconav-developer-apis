module UtilHelper
  def get_indices(params)
    pagination = {}
    if params["page"].present? && params["perPage"].present?
      start_index = params["page"].to_i * params["perPage"].to_i
      end_index = (params["page"].to_i + 1) * params["perPage"].to_i
      pagination = { start_index: start_index, end_index: end_index }
    elsif params["page"].present?
      start_index = params["page"].to_i * 10
      pagination = { start_index: start_index }
    elsif params["perPage"].present?
      end_index = params["perPage"].to_i
      pagination = { end_index: end_index }
    end

    params.merge(pagination)
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

  def build_pagination(params)
    {
      page: params[:page].present? ? params[:page].to_i : 1,
      per_page: params[:per_page].present? ? params[:per_page].to_i : 10,
    }
  end
end
