module ApplicationHelper
  def login_links
    if current_scribe
      link_to('log out', destroy_scribe_session_path, :method => :delete, :id => 'lot_out')
    elsif current_magician
      link_to("Bookshelf", magician_books_path(current_magician), :id => 'bookshelf') +
      link_to('log out', destroy_magician_session_path, :method => :delete, :id => 'lot_out')
    elsif current_muggle
      link_to("Bookshelf", muggle_books_path(current_muggle['id']), :id => 'bookshelf') +
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
    div_for obj, opts.merge(:data => {"#{obj.class.name.downcase}_id" => obj.id}.merge(opts[:data]||{}), :class => "div_with_data #{opts[:class]}"), &block
  end
  
  def site_logo
    tag.div :id => 'logo_holder' do
      link_to image_tag(asset_path('ways we mage logo.png'), :id => 'site_logo'), root_url
    end
  end
  
  def contact_us_link
    mail_to ENV['CUSTOMER_SUPPORT_EMAIL_ADDRESS'], 'Contact Us', :encode => 'javascript'
  end
  
  def footer_links
    tag.div :class => 'footer_links' do
      link_to('More Info', wwemc_path) +
      contact_us_link
    end
  end
  
  
  def markdown
    @renderer ||= Redcarpet::Render::HTML.new
    @markdown ||= Redcarpet::Markdown.new @renderer
  end
  
  def mark_up content
    markdown.render(content.to_s).html_safe
  end
  
  def google_fonts
    google_webfonts_init(:google => ['Anton', 'Cabin', 'Cinzel', 'Dosis', 'Josefin Sans', 'Noto Sans'])
  end
end
