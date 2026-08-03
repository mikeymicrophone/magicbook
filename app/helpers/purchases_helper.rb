module PurchasesHelper
  def wwemc_purchase(text, book = Book.featured)
    form_for(Purchase.new) do |f|
      f.hidden_field(:book_id, value: book.id) +
      tag.script(:src => 'https://checkout.stripe.com/checkout.js', :class => 'stripe-button', :data => {
        :key => ENV['STRIPE_PUBLISHABLE_KEY'],
        :amount => book.price_cents,
        :name => 'Ways We Mage',
        :description => book.title,
        :image => asset_url(image_path('ways-we-mage-logo-vertical.png')),
        :locale => 'auto',
        :label => text,
        :bitcoin => true
      })
    end
  end

  def coaching_purchase text, price
    tag.script :src => 'https://checkout.stripe.com/checkout.js', :class => 'stripe-button', :data => {
      :key => ENV['STRIPE_PUBLISHABLE_KEY'],
      :amount => price,
      :name => 'Ways We Mage',
      :description => 'Magic Coaching',
      :image => asset_url(image_path('ways-we-mage-logo-vertical.png')),
      :locale => 'auto',
      :label => text,
      :bitcoin => true
    }
  end
  
  def add_muggles_link book
    if current_magician && current_magician.purchased_books.where(:book => book).present?
      purchases = current_magician.purchased_books.where(:book => book, :purchase => current_magician.purchases.fresh).map(&:purchase)
      invitable_purchases = purchases.select { |purchase| purchase.invites_remaining > 0 }
      if invitable_purchases.present?
        return link_to 'Invite more friends', invite_muggles_path(:purchase_id => invitable_purchases.first), :class => 'book_purchase_link'
      end
    end

    wwemc_purchase 'Purchase and share', book
  end
  
  def open_graph_tags_for_purchase purchase
    tag.meta(:property => 'og:url', :content => claim_purchase_url(purchase)) +
    tag.meta(:property => 'og:type', :content => 'website') +
    tag.meta(:property => 'og:title', :content => purchase.books.first.title) +
    tag.meta(:property => 'og:description', :content => '$10 books and crowd-sourced listicles about Magic') +
    tag.meta(:property => 'og:image', :content => asset_url('ways-we-mage-logo-vertical.png'))
  end
end
