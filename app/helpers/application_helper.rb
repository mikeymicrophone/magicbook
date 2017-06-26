module ApplicationHelper
  def navigation_links
    link_to('books', books_path) +
    link_to('purchases', purchases_path) +
    link_to('editions', editions_path)
  end
end
