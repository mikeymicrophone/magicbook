module ApplicationHelper
  def login_links
    unless current_magician
      link_to("Sign in with Facebook", "/auth/facebook")
    else
      link_to("Review purchased books", magician_books_path(current_magician))
    end
  end
  
  def navigation_links
    link_to('books', books_path) +
    link_to('purchases', purchases_path) +
    link_to('editions', editions_path) +
    link_to('purchased_books', purchased_books_path) +
    link_to('magicians', magicians_path)
  end
  
  def div_with_data_for obj, opts = {}, &block
    div_for obj, opts.merge(:data => {"#{obj.class.name.downcase}_id" => obj.id}.merge(opts[:data]||{}), :class => :div_with_data), &block
  end
end
