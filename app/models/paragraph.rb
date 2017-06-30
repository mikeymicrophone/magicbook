class Paragraph < ApplicationRecord
  belongs_to :section
  has_one :chapter, :through => :section
  has_one :edition, :through => :chapter
  has_one :book, :through => :edition
  
  attr_accessor :book_id, :edition_id, :chapter_id
  
  def add_to_book table_of_contents
    if section = Section.where(:id => table_of_contents[:section_id]).take
      self.section_id = section.id
      save
    elsif chapter = Chapter.where(:id => table_of_contents[:chapter_id]).take
      section = chapter.sections.create
      self.section_id = section.id
      save
    elsif edition = Edition.where(:id => table_of_contents[:edition_id]).take
      chapter = edition.chapters.create
      section = chapter.sections.create
      self.section_id = section.id
      save
    elsif book = Book.where(:id => table_of_contents[:book_id]).take
      edition = book.editions.create
      chapter = edition.chapters.create
      section = chapter.sections.create
      self.section_id = section.id
      save
    end
  end
end
