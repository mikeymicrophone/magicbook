class Paragraph < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :editions, :through => :table_of_contents
  has_many :chapters, :through => :table_of_contents
  has_many :sections, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  attr_accessor :section, :chapter, :edition, :book
  
  def locate params
    @section = Section.find params[:section]
    @chapter = Chapter.find params[:chapter]
    @edition = Edition.find params[:edition]
    @book = Book.find params[:book]
    table_of_contents.create
  end
  
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
  
  def lead
    text[0..44]
  end
end
