class List < ApplicationRecord
  belongs_to :magician
  has_many :listed_items
  
  enum :mode => [:ordered, :randomized, :numbered]
  enum :privacy => [:draft, :unreviewed, :unreviewed_secret, :published, :secret, :rejected]
  
  validates :name, :presence => true
  
  scope :published, lambda { where :privacy => :published }
  scope :visible, lambda { where :privacy => [:unreviewed, :published] }
  scope :visible_to, lambda { |muggle| where :privacy => [:unreviewed_secret, :secret], :magician_id => muggle.magician_id }
  scope :unreviewed, lambda { where :privacy => [:unreviewed, :unreviewed_secret] }
  
  def ordered_items
    case mode
    when 'ordered', 'numbered'
      listed_items.ordered
    when 'randomized'
      listed_items.randomized
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