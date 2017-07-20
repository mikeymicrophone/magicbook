class List < ApplicationRecord
  belongs_to :magician
  has_many :listed_items
  
  enum mode: [:ordered, :randomized]
  
  validates :name, :presence => true
  
  scope :published, lambda { where.not :privacy => ['unpublished', 'private'] }
  
  def items
    case mode
    when 'ordered'
      listed_items.ordered
    when 'randomized'
      listed_items.randomized
    end
  end
end
