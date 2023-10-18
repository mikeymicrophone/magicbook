class Magician < ApplicationRecord
  has_many :purchases
  has_many :purchased_books, :through => :purchases
  has_many :books, :through => :purchases
  has_many :identifiers
  has_many :lists
  
  devise :database_authenticatable, :token_authenticatable, :recoverable, :rememberable, :trackable, :confirmable, :omniauthable, :omniauth_providers => [:facebook]

  def needs_access_technique?
    encrypted_password.blank?
  end
  
  def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |magician|
		magician.provider = auth.provider
		magician.uid = auth.uid
		magician.email = auth.info.email
		magician.password = Devise.friendly_token[0,20]
	  end
  end
  
 #  def self.reset_password_by_token(attributes={})
 #    recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
 #
 #    if recoverable.persisted?
 #      if recoverable.reset_password_period_valid?
 #        recoverable.reset_password(attributes[:password], attributes[:password_confirmation])
 #      else
 #        recoverable.errors.add(:reset_password_token, :expired)
 #      end
 #    end
 #
 #    recoverable.reset_password_token = original_token if recoverable.reset_password_token.present?
 #    recoverable
 #  end
end
