class List < ApplicationRecord
  belongs_to :magician
  has_many :listed_items
  
  validates :name, :presence => true
  
  scope :published, lambda { where.not :privacy => ['unpublished', 'private'] }
end
