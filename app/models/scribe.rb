class Scribe < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :confirmable
  
  def needs_access_technique?
    encrypted_password.blank?
  end
end
