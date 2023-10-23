module UtilHelper
  def get_indices(pagination)
    start_index = (pagination[:page].to_i - 1) * pagination[:per_page].to_i
    end_index = start_index + pagination[:per_page].to_i
    [start_index, end_index]
  end
end