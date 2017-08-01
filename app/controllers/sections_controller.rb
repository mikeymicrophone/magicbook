class SectionsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @section = Section.create section_params
    @chapter = Chapter.find params[:chapter]
    @section.locate params
  end
  
  def append
    @section = Section.find params[:id]
    @section.chapter = Chapter.find params[:chapterId]
    @section.edition = Edition.find params[:editionId]
    @section.book = Book.find params[:bookId]
    @paragraph = @section.paragraphs.new
  end
  
  def edit
    @section = Section.find params[:id]
    @chapter = Chapter.find params[:chapter_id]
    @chapter.edition = Edition.find params[:edition_id]
    @chapter.book = Book.find params[:book_id]
  end
  
  def update
    @section = Section.find params[:id]
    @chapter = Chapter.find params[:chapter]
    @section.update_attributes section_params
  end
  
  def promote
    @table_of_content = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :section_id => params[:id]).first
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => @table_of_content.chapter_id, :ordering => @previous_position.pred).first
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def destroy
    @table_of_content = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:id]).first
    @position = @table_of_content.ordering
    @table_of_content.destroy
    @subsequent = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id]).where(TableOfContent.arel_table[:ordering].gt(@position))
    @subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end
