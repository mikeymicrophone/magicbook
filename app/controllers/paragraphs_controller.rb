class ParagraphsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @paragraph = Paragraph.create paragraph_params
    @section = Section.find params[:section]
    @paragraph.locate params
  end
  
  def append
    @paragraph = Paragraph.find params[:id]
    @paragraph.section = Section.find params[:sectionId]
    @paragraph.chapter = Chapter.find params[:chapterId]
    @paragraph.edition = Edition.find params[:editionId]
    @paragraph.book = Book.find params[:bookId]
    @citation = @paragraph.citations.new
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @parent = @table_of_content.parent
    @succeeding = @parent.succeeding
    @last_position = @succeeding.last_child&.ordering.to_i
    @subsequent = @table_of_content.subsequent
    @table_of_content.update_attributes :section_id => @succeeding.section_id, :ordering => @last_position.next
    
    @subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def promote
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = @table_of_content.previous
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def edit
    @section = Section.find params[:section_id]
    @section.chapter = Chapter.find params[:chapter_id]
    @section.edition = Edition.find params[:edition_id]
    @section.book = Book.find params[:book_id]
    @paragraph = Paragraph.find params[:id]
  end
  
  def update
    @table_of_contents = TableOfContent.where(:book_id => params[:book], :edition_id => params[:edition], :chapter_id => params[:chapter], :section_id => params[:section], :paragraph_id => params[:id])
    
    @new_paragraph = Paragraph.create paragraph_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :paragraph_id, @new_paragraph.id }
    @section = Section.find params[:section]
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @table_of_content.destroy

    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
