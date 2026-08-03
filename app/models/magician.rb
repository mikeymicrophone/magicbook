class Magician < ApplicationRecord
  has_many :purchases
  has_many :purchased_books, :through => :purchases
  has_many :books, :through => :purchases
  has_many :identifiers
  has_many :lists
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :confirmable

  def ensure_authentication_token
    return authentication_token if authentication_token.present?

    update!(
      authentication_token: SecureRandom.urlsafe_base64(32),
      authentication_token_created_at: Time.current
    )
    authentication_token
  end

  def needs_access_technique?
    encrypted_password.blank?
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
