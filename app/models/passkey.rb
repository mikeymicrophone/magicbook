class Passkey < ApplicationRecord
  belongs_to :mage

  validates :external_id, :public_key, presence: true
  validates :external_id, uniqueness: true
end
