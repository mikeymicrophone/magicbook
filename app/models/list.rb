class List < ApplicationRecord
  belongs_to :magician
  has_many :listed_items
  
  enum :mode => [:ordered, :randomized, :numbered]
  enum :privacy => [:draft, :unreviewed, :unreviewed_secret, :published, :secret, :rejected, :removed]
  
  attr_default :mode, 'ordered'
  attr_default :privacy, 'unreviewed'
  
  validates :name, :presence => true
  
  scope :randomized, lambda { order 'random()' }
  scope :published, lambda { where :privacy => :published }
  scope :visible, lambda { where :privacy => [:unreviewed, :published] }
  scope :visible_to, lambda { |muggle| where :privacy => [:unreviewed_secret, :secret], :magician_id => muggle.magician_id }
  scope :unreviewed, lambda { where :privacy => [:unreviewed, :unreviewed_secret] }
  scope :in_draft, lambda { where :privacy => :draft }
  
  def ordered_items
    case mode
    when 'ordered', 'numbered'
      listed_items.remaining.ordered
    when 'randomized'
      listed_items.remaining.randomized
    end
  end
  
  def items_for muggle
    if muggle.magician == magician
      ordered_items.for_my_muggles
    else
      ordered_items.for_muggles
    end
  end
  
  def published_items
    ordered_items.published
  end
end
