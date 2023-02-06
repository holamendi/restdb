module PaginationHelper
  def pagination_params(params)
    page = params[:page].to_i
    page = 1 if page.nil? || page.to_i <= 0

    page_size = params[:page_size].to_i
    page_size = 200 unless page_size.to_i.between?(10, 200)

    [page, page_size]
  end
end
