class Purchase < ApplicationRecord
  belongs_to :magician, :optional => true
  has_many :purchased_books
  has_many :books, :through => :purchased_books
  has_many :muggles
  
  attr_accessor :fulfill, :ramp
  
  scope :fresh, lambda { where Purchase.arel_table[:created_at].gt 3.days.ago }
  
  before_create :default_book, :populate_token
  after_create :process_payment, :attach_magician
  
  def attach_magician
    @magician = Magician.find_or_create_by :email => email
    update_attribute :magician_id, @magician.id
  end
  
  def process_payment
    if ramp
      @fulfill = true
      self.stripe_token = 'ramp'
      return
    end
    
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
  
  def invites_remaining
    4 - muggles.count
  end
  
  def fresh?
    created_at > 3.days.ago
  end
  
  def can_invite_muggles?
    invites_remaining.present? && fresh?
  end
  
  def populate_token
    self.token = SecureRandom.hex
  end
end
