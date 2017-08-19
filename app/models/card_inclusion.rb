class CardInclusion < ApplicationRecord
  belongs_to :card
  belongs_to :piece, :polymorphic => true
  attr_accessor :card_name
end
