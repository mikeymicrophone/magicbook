class CardFunctionAssignment < ApplicationRecord
  belongs_to :card_concept
  belongs_to :card_function

  validates :card_function_id, uniqueness: { scope: :card_concept_id }
end
