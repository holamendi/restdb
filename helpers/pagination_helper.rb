module PaginationHelper
  def pagination_params(params)
    page = params[:page].to_i
    page = 1 if page <= 0

    page_size = params[:page_size].to_i
    page_size = 200 unless page_size.between?(10, 200)

    [page, page_size]
  end
end
