module ApplicationHelper
  def login_links
    if current_mage
      link_to('log out', destroy_mage_session_path, method: :delete, id: 'log_out')
    else
      link_to('Sign in', new_mage_session_path, id: 'password_login')
    end
  end
  
  def shelf
    tag.div :class => 'header_links' do
      if current_mage
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Sets', card_sets_path, :class => 'bookshelf') +
        link_to('Functions', card_functions_path, :class => 'bookshelf')
      else
        link_to('Free Chapter', free_book_chapters_path(Book.featured)) +
        link_to('Bookshelf', books_path, :class => 'bookshelf') +
        link_to('Lists', lists_path, :class => 'bookshelf') +
        link_to('Sets', card_sets_path, :class => 'bookshelf') +
        link_to('Functions', card_functions_path, :class => 'bookshelf')
      end
    end
  end
  
  def navigation_links
    links = [
      link_to('home', root_url),
      link_to('books', books_path),
      link_to('purchases', purchases_path),
      link_to('editions', editions_path),
      link_to('purchased_books', purchased_books_path)
    ]
    links << link_to('mages', mages_path) if current_mage&.admin?
    safe_join(links)
  end

  def review_kit
    return unless current_mage&.admin?

    tag.div class: 'header_links' do
      link_to('Review new lists', review_lists_path) +
        link_to('Review new items', review_listed_items_path)
    end
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
        "#{Book.featured.formatted_price} books and crowd-sourced listicles about Magic"
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
  
  def open_graph_tags
    tag.meta(:property => 'og:url', :content => root_url) +
    tag.meta(:property => 'og:type', :content => 'website') +
    tag.meta(:property => 'og:title', :content => 'Ways We Mage') +
    tag.meta(:property => 'og:description', :content => "#{Book.featured.formatted_price} ebooks and crowd-sourced listicles about Magic") +
    tag.meta(:property => 'og:image', :content => asset_url('ways-we-mage-logo-vertical.png'))
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
    <link href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100&family=Antic&family=Anton&family=Cabin:wght@400;500;600;700&family=Changa:wght@300&family=Cinzel:wght@400;500;600&family=Crushed&family=Dosis:wght@300;400;500&family=Fondamento&family=Jaldi&family=Josefin+Sans:wght@300&family=Noto+Sans:wght@200&family=Righteous&family=Syncopate&display=swap" rel="stylesheet">'.html_safe
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
