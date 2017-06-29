class Purchase < ApplicationRecord
  has_many :purchased_books
  has_many :books, :through => :purchased_books
  
  attr_accessor :fulfill
  
  before_create :default_book
  after_create :process_payment, :attach_magician
  
  def attach_magician
    @magician = Magician.find_or_create_by :email => email
  end
  
  def process_payment
    charge = Stripe::Charge.create(
      :amount => price,
      :currency => "usd",
      :source => stripe_token,
      :description => books.map(&:title).to_sentence
    )
    
    if charge.paid?
      self.stripe_token = charge.id
      @fulfill = true
    else
      @fulfill = false
    end
  end
  
  def default_book
    books << Book.find(ENV['DEFAULT_BOOK_IDS']) if books.empty?
  end
  
  def price
    books.count * 200
  end
end
