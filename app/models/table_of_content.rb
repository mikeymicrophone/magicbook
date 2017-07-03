class TableOfContent < ActiveRecord::Base
  belongs_to :book, :optional => true
  belongs_to :edition, :optional => true
  belongs_to :chapter, :optional => true
  belongs_to :section, :optional => true
  belongs_to :paragraph, :optional => true
  belongs_to :citation, :optional => true
  
  before_create :locate
  
  def locate
    self.paragraph ||= citation&.paragraph
    self.section ||= citation&.section || paragraph&.section
    self.chapter ||= citation&.chapter || paragraph&.chapter || section&.chapter
    self.edition ||= citation&.edition || paragraph&.edition || section&.edition || chapter&.edition
    self.book ||= citation&.book || paragraph&.book || section&.book || chapter&.book || edition&.book
  end
end
