module PurchasesHelper
  def wwemc_purchase
    form_for Purchase.new do |f|
      tag.script :src => 'https://checkout.stripe.com/checkout.js', :class => 'stripe-button', :data => {
        :key => ENV['STRIPE_PUBLISHABLE_KEY'],
        :amount => '200',
        :name => 'Mikey Microphone',
        :description => 'Ways We Enjoy Magic Cards',
        :image => 'https://stripe.com/img/documentation/checkout/marketplace.png',
        :locale => 'auto'
      }
    end
  end
end
