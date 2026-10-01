class Format < ApplicationRecord
  has_many :format_sets, dependent: :restrict_with_exception
  has_many :current_format_sets, -> { current }, class_name: "FormatSet"
  # The sets legal today. format_sets also keeps the rotated and upcoming ones.
  has_many :card_sets, through: :current_format_sets
  has_many :cards, through: :card_sets
  has_many :card_concepts, through: :cards

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
