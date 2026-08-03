class CardConcept < ApplicationRecord
  has_many :cards, dependent: :restrict_with_exception
  has_many :card_function_assignments, dependent: :destroy
  has_many :card_functions, through: :card_function_assignments

  validates :name, presence: true, uniqueness: true
  validates :oracle_id, uniqueness: true, allow_nil: true

  def preferred_printing
    cards.preferred.first || cards.order(:released_on, :id).first
  end
end
