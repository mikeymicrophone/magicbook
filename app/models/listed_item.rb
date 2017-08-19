class ListedItem < ApplicationRecord
  belongs_to :list
  belongs_to :content, :polymorphic => true, :optional => true
  has_many :card_inclusions, :as => :piece
  has_many :cards, :through => :card_inclusions
  
  enum :privacy => [:draft, :unreviewed, :unreviewed_secret, :published, :secret, :rejected, :removed, :suggested]
  
  attr_default :privacy, 'unreviewed'
  
  scope :ordered, lambda { order :ordering }
  scope :randomized, lambda { order 'random()' }
  scope :remaining, lambda { where.not :privacy => [:rejected, :removed, :suggested] }
  scope :for_my_muggles, lambda { where :privacy => [:unreviewed, :unreviewed_secret, :published, :secret] }
  scope :for_muggles, lambda { where :privacy => [:unreviewed, :published] }
  scope :published, lambda { where :privacy => :published }
  scope :unreviewed, lambda { where :privacy => [:unreviewed, :unreviewed_secret] }
  scope :suggested, lambda { where :privacy => :suggested }
  
  before_create :sequence
  before_update :remove_from_sequence
  
  def sequence
    self.ordering = list.listed_items.remaining.ordered.last&.ordering.to_i + 1
  end
  
  def remove_from_sequence
    if privacy_changed? && ['removed', 'rejected'].include?(privacy)
      previous_ordering = ordering
      self.ordering = nil
    end
    if previous_ordering
      subsequent_items = list.listed_items.remaining.where(ListedItem.arel_table[:ordering].gt previous_ordering)
      subsequent_items.each do |item|
        item.update_attribute :ordering, item.ordering - 1
      end
    end
  end
end
