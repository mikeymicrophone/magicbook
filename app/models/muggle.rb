class Muggle < ApplicationRecord
  belongs_to :magician
  belongs_to :purchase
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable
         
  before_validation :set_password_to_card_name
  validate :number_of_invited_muggles, :time_since_purchase
  validates :email, :presence => true
  
  def select_card_name
    card_name = ''
    until card_name.length > 8
      card_name = File.readlines(Rails.root.join('config', 'locales', 'card_names.txt')).sample
    end
    card_name.chomp
  end
  
  def set_password_to_card_name
    self.password = self.password_confirmation = select_card_name
  end
  
  def number_of_invited_muggles
    errors.add(:base, "Four muggles have already been shared with.  Please purchase another license to share with more.") if Muggle.where(:purchase_id => purchase_id).count > 3
  end
  
  def time_since_purchase
    errors.add(:base, "This purchase was made more than three days ago.") if purchase.created_at < 3.days.ago
  end
end
