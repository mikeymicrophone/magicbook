class FormatSet < ApplicationRecord
  belongs_to :format
  belongs_to :card_set

  validates :card_set_id, uniqueness: { scope: :format_id }
end
