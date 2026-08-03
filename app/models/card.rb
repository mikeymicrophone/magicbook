class Card < ApplicationRecord
  include FlagShihTzu
  
  # Cards are printings. CardConcept is the canonical game object shared by
  # reprints, while this record retains the image and set-specific details.
  belongs_to :card_concept
  belongs_to :card_set, optional: true

  has_many :card_inclusions
  has_many :listed_items, :through => :card_inclusions
  
  before_validation :associate_card_concept, on: :create

  validates :name, presence: true
  validates :scryfall_id, uniqueness: true, allow_nil: true

  has_flags 1 => :artifact,
            2 => :creature,
            3 => :enchantment,
            4 => :instant,
            5 => :land,
            6 => :planeswalker,
            7 => :sorcery,
            8 => :tribal,
            :column => 'types'
            
  
  has_flags 1 => :white,
            2 => :blue,
            3 => :black,
            4 => :red,
            5 => :green,
            :column => 'colors'
            
  scope :unmultiversed, lambda { where :multiverse_id => nil }
  scope :preferred, -> { where(preferred: true) }

  def self.lookup_by_name(name)
    preferred.find_by(name: name) || find_by(name: name)
  end

  def self.search_by_name(query)
    term = query.to_s.strip
    return none if term.blank?

    matches = where("name ILIKE ?", "%#{sanitize_sql_like(term)}%").order(:name)
    preferred_matches = matches.preferred
    preferred_matches.exists? ? preferred_matches : matches
  end

  private

  def associate_card_concept
    return if card_concept || name.blank?

    self.card_concept = CardConcept.find_or_initialize_by(name: name)
  end
end
