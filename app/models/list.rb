class List < ApplicationRecord
  belongs_to :mage
  has_many :listed_items
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  
  enum :mode, [:ordered, :randomized, :numbered]
  enum :privacy, [:draft, :unreviewed, :unreviewed_secret, :published, :secret, :rejected, :removed]
  enum :suggestability, [:defer, :notify, :languish]
  enum :pin, [:examplary, :prominent, :suggestion_seeking, :deferred]
  
  attr_default :mode, 'ordered'
  attr_default :privacy, 'unreviewed'
  attr_default :suggestability, 'notify'
  
  validates :name, :presence => true#, :uniqueness => true
  
  scope :recent, lambda { order 'created_at desc' }
  scope :alphabetical, lambda { order :name }
  scope :randomized, lambda { order "" }
  scope :published, lambda { where :privacy => :published }
  scope :visible, lambda { where :privacy => [:unreviewed, :published] }
  scope :visible_to, lambda { |mage| where :privacy => [:unreviewed_secret, :secret], :mage_id => mage.id }
  scope :unreviewed, lambda { where :privacy => [:unreviewed, :unreviewed_secret] }
  scope :in_draft, lambda { where :privacy => :draft }
  scope :with_cards_legal_in, ->(format) { joins(listed_items: :cards).merge(Card.legal_in(format)).distinct }
  
  def ordered_items
    case mode
    when 'ordered', 'numbered'
      listed_items.remaining.ordered
    when 'randomized'
      listed_items.remaining.randomized
    end
  end
  
  def items_for mage
    if mage.received_invitations.where(inviter: self.mage).exists?
      ordered_items.for_invitees
    else
      ordered_items.for_others
    end
  end
  
  def published_items
    ordered_items.published
  end
  
  def name_part
    name[0..50]
  end
  
  def to_param
    "#{id}-#{permalink}"
  end

  def permalink
    name.gsub(/[^a-z0-9]+/i, '-')
  end
end
