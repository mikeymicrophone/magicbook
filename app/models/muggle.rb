class Muggle < ApplicationRecord
  belongs_to :magician
  belongs_to :purchase
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable
         
  before_validation :set_password_to_card_name
  
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
end
