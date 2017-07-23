class ListedItem < ApplicationRecord
  belongs_to :list
  belongs_to :content, :polymorphic => true, :optional => true
  
  enum :privacy => [:draft, :unreviewed, :unreviewed_secret, :published, :secret, :rejected]
  
  attr_default :privacy, 'unreviewed'
  
  scope :ordered, lambda { order :ordering }
  scope :randomized, lambda { order 'random()' }
  scope :for_my_muggles, lambda { where :privacy => [:unreviewed, :unreviewed_secret, :published, :secret] }
  scope :for_muggles, lambda { where :privacy => [:unreviewed, :published] }
  scope :published, lambda { where :privacy => :published }
  scope :unreviewed, lambda { where :privacy => [:unreviewed, :unreviewed_secret] }
  
  before_create :sequence
  
  def sequence
    self.ordering = list.listed_items.ordered.last&.ordering.to_i + 1
  end
end
