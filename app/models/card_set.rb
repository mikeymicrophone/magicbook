class CardSet < ApplicationRecord
  RAW_TYPE_CATEGORIES = {
    'core' => :premier,
    'expansion' => :premier,
    'starter' => :premier,
    'commander' => :supplemental,
    'duel_deck' => :supplemental,
    'draft_innovation' => :supplemental,
    'planechase' => :supplemental,
    'archenemy' => :supplemental,
    'arsenal' => :supplemental,
    'premium_deck' => :supplemental,
    'spellbook' => :supplemental,
    'masters' => :reprint,
    'masterpiece' => :reprint,
    'from_the_vault' => :reprint,
    'eternal' => :reprint,
    'promo' => :promo,
    'token' => :token,
    'funny' => :novelty,
    'minigame' => :novelty,
    'vanguard' => :novelty
  }.freeze

  has_many :cards, dependent: :restrict_with_exception

  enum :category, {
    premier: 0,
    supplemental: 1,
    reprint: 2,
    promo: 3,
    token: 4,
    novelty: 5,
    special: 6
  }

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :browseable, -> { where.not(category: [:promo, :token, :special]) }

  def self.category_for_set_type(set_type)
    RAW_TYPE_CATEGORIES.fetch(set_type, :special)
  end

  def to_param
    code
  end
end
