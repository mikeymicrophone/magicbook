module ApplicationHelper
  def login_links
    if current_scribe
      link_to('log out', destroy_scribe_session_path, :method => :delete, :id => 'lot_out')
    elsif current_magician
      link_to("Read books", magician_books_path(current_magician)) +
      link_to('log out', destroy_magician_session_path, :method => :delete, :id => 'lot_out')
    elsif current_muggle
      link_to("Read books", muggle_books_path(current_muggle['id'])) +
      link_to('log out', destroy_muggle_session_path, :method => :delete, :id => 'lot_out')
    else
      link_to("Sign in with Facebook", "/auth/facebook", :id => 'facebook_login') +
      tag.br +
      link_to("Sign in with password", new_magician_session_path, :id => 'password_login')
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
  
  def site_logo
    tag.div :id => 'logo_holder' do
      link_to image_tag(asset_path('ways we mage logo.png'), :id => 'site_logo'), root_url
    end
  end
  
  def google_fonts
    google_webfonts_init(:google => ['Anton', 'Cabin', 'Josefin Sans', 'Noto Sans'])
  end
end
