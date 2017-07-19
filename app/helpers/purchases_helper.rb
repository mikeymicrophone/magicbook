module PurchasesHelper
  def wwemc_purchase
    form_for Purchase.new do |f|
      tag.script :src => 'https://checkout.stripe.com/checkout.js', :class => 'stripe-button', :data => {
        :key => ENV['STRIPE_PUBLISHABLE_KEY'],
        :amount => '200',
        :name => 'Ways We Mage',
        :description => 'Ways We Enjoy Magic Cards',
        :image => 'https://stripe.com/img/documentation/checkout/marketplace.png',
        :locale => 'auto',
        :label => "It's just $2"
      }
    end
  end
end
