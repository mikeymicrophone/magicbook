class Citation < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :editions, :through => :table_of_contents
  has_many :chapters, :through => :table_of_contents
  has_many :sections, :through => :table_of_contents
  has_many :paragraphs, :through => :table_of_contents
  
  attr_accessor :paragraph, :section, :chapter, :edition, :book
  
  def locate params
    @paragraph = Paragraph.find params[:paragraph]
    @section = Section.find params[:section]
    @chapter = Chapter.find params[:chapter]
    @edition = Edition.find params[:edition]
    @book = Book.find params[:book]
    table_of_contents.create
  end
end
