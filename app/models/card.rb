class Card < ApplicationRecord
  include FlagShihTzu
  
  # Cards are printings. CardConcept is the canonical game object shared by
  # reprints, while this record retains the image and set-specific details.
  belongs_to :card_concept
  belongs_to :card_set, optional: true

  has_many :format_sets, through: :card_set
  has_many :printing_formats, through: :format_sets, source: :format
  has_many :card_inclusions
  has_many :listed_items, through: :card_inclusions, source: :piece, source_type: 'ListedItem'
  has_many :lists, through: :listed_items
  
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
  # A printing is *printed in* a format when its own set belongs to that
  # format. A card is *legal in* a format when any printing of its canonical
  # CardConcept is printed in that format.
  scope :printed_in, ->(format) {
    joins(card_set: :format_sets).where(format_sets: { format_id: format }).distinct
  }
  scope :legal_in, ->(format) {
    where(card_concept_id: CardConcept.legal_in(format).select(:id))
  }
  scope :newest_first, -> { order(Arel.sql('released_on DESC NULLS LAST'), id: :desc) }

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

  def newer_printings
    return Card.none if released_on.blank?

    card_concept.cards.where('cards.released_on > ?', released_on).newest_first
  end

  def has_newer_printing?
    newer_printings.exists?
  end

  def legal_in?(format)
    card_concept.legal_in?(format)
  end

  # This is the printing to show when a format-specific view needs current
  # artwork. It may be newer than the printing stored in a historical list.
  def latest_printing_for(format)
    card_concept.latest_printing_in(format)
  end

  private

  def associate_card_concept
    return if card_concept || name.blank?

    self.card_concept = CardConcept.find_or_initialize_by(name: name)
  end
end
