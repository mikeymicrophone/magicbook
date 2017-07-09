class TableOfContent < ActiveRecord::Base
  belongs_to :book, :optional => true
  belongs_to :edition, :optional => true
  belongs_to :chapter, :optional => true
  belongs_to :section, :optional => true
  belongs_to :paragraph, :optional => true
  belongs_to :citation, :optional => true
  
  before_create :locate, :sequence
  
  def locate
    self.paragraph ||= citation&.paragraph
    self.section ||= citation&.section || paragraph&.section
    self.chapter ||= citation&.chapter || paragraph&.chapter || section&.chapter
    self.edition ||= citation&.edition || paragraph&.edition || section&.edition || chapter&.edition
    self.book ||= citation&.book || paragraph&.book || section&.book || chapter&.book || edition&.book
  end
  
  def sequence
    if ordering.blank?
      if citation_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id, :section_id => section_id, :paragraph_id => paragraph_id).where.not(:citation_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif paragraph_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id, :section_id => section_id).where.not(:paragraph_id => nil).where(:citation_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif section_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id).where.not(:section_id => nil).where(:paragraph_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif chapter_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id).where.not(:chapter_id => nil).where(:section_id => nil).order(:ordering).last&.ordering.to_i + 1
      end
    else
      
    end
  end
end
