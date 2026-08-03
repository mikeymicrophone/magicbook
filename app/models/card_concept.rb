class CardConcept < ApplicationRecord
  has_many :cards, dependent: :restrict_with_exception
  has_many :format_sets, through: :cards
  has_many :formats, through: :format_sets
  has_many :card_function_assignments, dependent: :destroy
  has_many :card_functions, through: :card_function_assignments

  validates :name, presence: true, uniqueness: true
  validates :oracle_id, uniqueness: true, allow_nil: true

  scope :legal_in, ->(format) {
    joins(cards: { card_set: :format_sets }).where(format_sets: { format_id: format }).distinct
  }

  def preferred_printing
    cards.preferred.first || cards.order(:released_on, :id).first
  end

  def legal_in?(format)
    formats.where(id: format).exists?
  end

  def printings_in(format)
    cards.printed_in(format)
  end

  def latest_printing_in(format)
    printings_in(format).newest_first.first
  end
end
