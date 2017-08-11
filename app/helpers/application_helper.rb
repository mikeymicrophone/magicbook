module ApplicationHelper
  def login_links
    if current_scribe
      link_to('log out', destroy_scribe_session_path, :method => :delete, :id => 'lot_out')
    elsif current_magician
      link_to('log out', destroy_magician_session_path, :method => :delete, :id => 'lot_out')
    elsif current_muggle
      link_to('log out', destroy_muggle_session_path, :method => :delete, :id => 'lot_out')
    else
      link_to('Sign in with Facebook', "/auth/facebook", :id => 'facebook_login') +
      tag.br +
      link_to('Sign in with password', new_magician_session_path, :id => 'password_login')
    end
  end
  
  def shelf
    tag.div :class => 'header_links' do
      if current_scribe
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf')
      elsif current_magician
        link_to('Bookshelf', magician_books_path(current_magician), :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf')
      elsif current_muggle
        link_to('Bookshelf', muggle_books_path(current_muggle['id']), :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf')
      else
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf')
      end
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
      tag.div(:class => 'hex', :id => 'site_title') do
        link_to(image_tag(asset_path('ways we mage logo.png'), :id => 'site_logo', :class => 'hex'), root_url)
      end +
      tag.div(:id => 'site_subtitle') do
        "$2 books and crowd-sourced listicles about Magic"
      end
    end
  end
  
  def contact_us_link
    mail_to ENV['CUSTOMER_SUPPORT_EMAIL_ADDRESS'], 'Contact Us', :encode => 'javascript'
  end
  
  def footer_call_to_action
    tag.div :class => 'footer_links' do
      wwemc_purchase "I value my intellectual life.  I want to challenge myself."
    end
  end
  
  def footer_links
    tag.div :class => 'footer_links' do
      link_to('More Info', wwemc_path) +
      contact_us_link +
      link_to('List FAQ', faq_lists_path)
    end
  end
  
  def facebook_initializer
    tag.script do
      %Q!window.fbAsyncInit = function() {
        FB.init({
          appId      : '#{ENV['FACEBOOK_APP_ID']}',
          cookie     : true,
          xfbml      : true,
          version    : 'v2.8'
        });
        FB.AppEvents.logPageView();   
      };

      (function(d, s, id){
         var js, fjs = d.getElementsByTagName(s)[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement(s); js.id = id;
         js.src = "//connect.facebook.net/en_US/sdk.js";
         fjs.parentNode.insertBefore(js, fjs);
       }(document, 'script', 'facebook-jssdk'));!.html_safe
    end
  end
  
  def open_graph_tags
    tag.div :class => 'open_graph_tags' do
      tag.meta(:property => 'og:url', :content => root_url) +
      tag.meta(:property => 'og:type', :content => 'website') +
      tag.meta(:property => 'og:title', :content => 'Ways We Mage') +
      tag.meta(:property => 'og:description', :content => '$2 ebooks and crowd-sourced listicles about Magic') +
      tag.meta(:property => 'og:image', :content => asset_url('ways-we-mage-logo-vertical.png')) +
      tag.meta(:property => 'fb:app_id', :content => ENV['FACEBOOK_APP_ID'])
    end
  end
  
  def facebook_quote_plugin
    tag.div :class => 'fb-quote'
  end
  
  def tapped_out_plugin
    tag.script :src => 'http://tappedout.net/tappedout.js'
  end
  
  def autocard_plugin
    tag.script :src => 'https://sites.google.com/site/themunsonsapps/mtg/autocard.js'
  end
  
  def markdown
    @renderer ||= Redcarpet::Render::HTML.new
    @markdown ||= Redcarpet::Markdown.new @renderer
  end
  
  def mark_up content
    markdown.render(content.to_s).html_safe
  end
  
  def google_fonts
    google_webfonts_init :google => selected_fonts
  end
  
  def selected_fonts
    ['Advent Pro', 'Antic', 'Anton', 'Cabin', 'Changa', 'Cinzel', 'Crushed', 'Dosis', 'Jaldi', 'Josefin Sans', 'Noto Sans', 'Righteous', 'Syncopate']
  end
end
