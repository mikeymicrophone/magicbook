class ListedItem < ApplicationRecord
  belongs_to :list
  belongs_to :content, :polymorphic => true, :optional => true
  
  scope :ordered, lambda { order :ordering }
  scope :randomized, lambda { order 'random()' }
  
  before_create :sequence
  
  def sequence
    self.ordering = list.listed_items.ordered.last.ordering.to_i + 1
  end
end
