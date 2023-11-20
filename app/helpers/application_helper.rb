module ApplicationHelper
  def login_links
    if current_scribe
      link_to('log out', destroy_scribe_session_path, :method => :delete, :id => 'lot_out')
    elsif current_magician
      link_to('log out', destroy_magician_session_path, :method => :delete, :id => 'lot_out')
    elsif current_muggle
      link_to('log out', destroy_muggle_session_path, :method => :delete, :id => 'lot_out')
    else
      facebook_login_button +
      tag.br +
      link_to('Sign in', new_magician_session_path, :id => 'password_login')
    end
  end
  
  def shelf
    tag.div :class => 'header_links' do
      if current_scribe
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Coaching', coaching_path, :class => 'bookshelf')
      elsif current_magician
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', magician_books_path(current_magician), :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Coaching', coaching_path, :class => 'bookshelf')
      elsif current_muggle
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', muggle_books_path(current_muggle['id']), :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Coaching', coaching_path, :class => 'bookshelf')
      else
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Coaching', coaching_path, :class => 'bookshelf')
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
        "$#{ENV['CURRENT_BOOK_PRICE'].to_i / 100} books and crowd-sourced listicles about Magic"
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
      link_to('List FAQ', faq_lists_path) +
      link_to('Privacy', privacy_policy_path)
    end
  end
  
  def facebook_initializer
    "<div id='fb-root'></div><script async defer crossorigin='anonymous' src='https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v18.0&appId=#{ENV['FACEBOOK_APP_ID']}' nonce='iA4eUord'></script>".html_safe
  end
  
  def open_graph_tags
    tag.meta(:property => 'og:url', :content => root_url) +
    tag.meta(:property => 'og:type', :content => 'website') +
    tag.meta(:property => 'og:title', :content => 'Ways We Mage') +
    tag.meta(:property => 'og:description', :content => "$#{ENV['CURRENT_BOOK_PRICE'].to_i / 100} ebooks and crowd-sourced listicles about Magic") +
    tag.meta(:property => 'og:image', :content => asset_url('ways-we-mage-logo-vertical.png')) +
    tag.meta(:property => 'fb:app_id', :content => ENV['FACEBOOK_APP_ID'])
  end
  
  def facebook_login_button
    '<div class="fb-login-button" data-width="200" data-size="" data-button-type="" data-layout="" data-auto-logout-link="false" data-use-continue-as="false"></div>'.html_safe
  end
  
  def facebook_quote_plugin
    tag.div :class => 'fb-quote'
  end
  
  def facebook_share_button
    tag.div :class => "fb-share-button", :data => {:href => root_url, :layout => 'button'}
  end
  
  def facebook_pixel
    tag.script do
    "!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
    n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
    document,'script','https://connect.facebook.net/en_US/fbevents.js');
    fbq('init', '#{ENV['FACEBOOK_PIXEL_ID']}');
    fbq('track', 'PageView');".html_safe
    end +
    tag.noscript do
      tag.img :height =>"1", :width => "1", :style => "display:none", 
      :src => "https://www.facebook.com/tr?id=#{ENV['FACEBOOK_PIXEL_ID']}&ev=PageView&noscript=1"
    end
  end
  
  def tapped_out_plugin
    tag.script :src => 'http://tappedout.net/tappedout.js'
  end
  
  def autocard_plugin
    tag.script :src => 'https://sites.google.com/site/themunsonsapps/mtg/autocard.js'
  end
  
  def google_fonts
    '<link rel="preconnect" href="https://fonts.googleapis.com">
     <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100&family=Antic&family=Anton&family=Cabin&family=Changa:wght@300&family=Cinzel&family=Crushed&family=Dosis:wght@300&family=Fondamento&family=Jaldi&family=Josefin+Sans:wght@300&family=Noto+Sans:wght@200&family=Righteous&family=Syncopate&display=swap" rel="stylesheet">'.html_safe
  end
  
  def selected_fonts
    # ['Fontdiner Swanky', 'Goudy Bookletter 1911', 'IM Fell French Canon SC', 'IM Fell Great Primer SC', Modern Antiqua', 'UnifrakturCook', 'Vast Shadow']
    ['Advent Pro', 'Antic', 'Anton', 'Cabin', 'Changa', 'Cinzel', 'Crushed', 'Dosis', 'Fondamento', 'Jaldi', 'Josefin Sans:300', 'Noto Sans', 'Righteous', 'Syncopate']
  end
  
  def google_analytics
    """
      <!-- Google tag (gtag.js) -->
      <script async src='https://www.googletagmanager.com/gtag/js?id=#{ENV['GOOGLE_ANALYTICS_MEASUREMENT_ID']}'></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', '#{ENV['GOOGLE_ANALYTICS_MEASUREMENT_ID']}');
      </script>
    """.html_safe
  end
  
  def clearboth
    tag.div :class => 'clearboth'
  end
end
