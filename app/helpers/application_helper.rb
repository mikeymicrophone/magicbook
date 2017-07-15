module ApplicationHelper
  def login_links
    if current_magician
      link_to("Read books", magician_books_path(current_magician)) +
      link_to('lot out', destroy_magician_session_path, :method => :delete)
    elsif current_muggle
      link_to("Read books", muggle_books_path(current_muggle['id'])) +
      link_to('lot out', destroy_muggle_session_path, :method => :delete)
    else
      link_to("Sign in with Facebook", "/auth/facebook")
    end
  end
  
  def navigation_links
    link_to('home', root_url) +
    link_to('books', books_path) +
    link_to('purchases', purchases_path) +
    link_to('editions', editions_path) +
    link_to('purchased_books', purchased_books_path) +
    link_to('magicians', magicians_path)
  end
  
  def div_with_data_for obj, opts = {}, &block
    div_for obj, opts.merge(:data => {"#{obj.class.name.downcase}_id" => obj.id}.merge(opts[:data]||{}), :class => :div_with_data), &block
  end
  
  def google_fonts
    google_webfonts_init(:google => ['Noto Sans'])
  end
end
