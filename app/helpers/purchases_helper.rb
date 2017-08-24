module PurchasesHelper
  def wwemc_purchase text, options = {}
    form_for(Purchase.new) do |f|
      tag.script :src => 'https://checkout.stripe.com/checkout.js', :class => 'stripe-button', :data => {
        :key => ENV['STRIPE_PUBLISHABLE_KEY'],
        :amount => '200',
        :name => 'Ways We Mage',
        :description => 'Ways We Enjoy Magic Cards',
        :image => asset_url(image_path('ways-we-mage-logo-vertical.png')),
        :locale => 'auto',
        :label => text,
        :bitcoin => true
      }
    end +
    tag.div(:class => 'center') do
      facebook_share_button unless options[:sharer] == false
    end
  end
  
  def add_muggles_link book
    if current_magician
      if current_magician.purchased_books.where(:book => book).present?
        purchases = current_magician.purchased_books.where(:book => book, :purchase => current_magician.purchases.fresh).map(&:purchase)
        invitable_purchases = purchases.select { |purchase| purchase.invites_remaining > 0 }
        if invitable_purchases.present?
          link_to 'Invite more friends', invite_muggles_path(:purchase_id => invitable_purchases.first), :class => 'book_purchase_link'
        else
          link_to 'Purchase and share', root_url, :class => 'book_purchase_link'
        end
      else 
        link_to 'Purchase and share', root_url, :class => 'book_purchase_link'
      end
    elsif current_muggle
      link_to 'Purchase and share', root_url, :class => 'book_purchase_link'
    else
      link_to 'Purchase and share', root_url, :class => 'book_purchase_link purchase_trigger'
    end
  end
  
  def open_graph_tags_for_purchase purchase
    tag.meta(:property => 'og:url', :content => claim_purchase_url(purchase)) +
    tag.meta(:property => 'og:type', :content => 'website') +
    tag.meta(:property => 'og:title', :content => purchase.books.first.title) +
    tag.meta(:property => 'og:description', :content => '$2 books and crowd-sourced listicles about Magic') +
    tag.meta(:property => 'og:image', :content => asset_url('ways-we-mage-logo-vertical.png')) +
    tag.meta(:property => 'fb:app_id', :content => ENV['FACEBOOK_APP_ID'])
  end
end
