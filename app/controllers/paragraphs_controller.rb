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
    @table_of_content = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id], :paragraph_id => params[:id]).first
    @position = @table_of_content.ordering
    @section = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id]).first
    @subsequent_section = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :ordering => @section.ordering.next).first
    @last_position = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => @subsequent_section.section_id).order(:ordering).last&.ordering.to_i
    @table_of_content.update_attributes :section_id => @subsequent_section.section_id, :ordering => @last_position.next
    
    @subsequent = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id]).where(TableOfContent.arel_table[:ordering].gt(@position))
    @subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def promote
    @table_of_content = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :paragraph_id => params[:id]).first
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => @table_of_content.chapter_id, :section_id => @table_of_content.section_id, :ordering => @previous_position.pred).first
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
    @paragraph = Paragraph.find params[:id]
    @section = Section.find params[:section]
    @edition = Edition.find params[:edition]
    @book = Book.find params[:book]
    
    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch + 1
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book
    
    @new_paragraph = Paragraph.create paragraph_params
    
    @new_edition.table_of_contents.each do |table_of_content|
      if table_of_content.paragraph_id == @paragraph.id
        table_of_content.update_attribute :paragraph_id, @new_paragraph.id
      end
    end
  end
  
  def destroy
    @table_of_content = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id], :paragraph_id => params[:id]).first
    @position = @table_of_content.ordering
    @table_of_content.destroy
    @subsequent = TableOfContent.paragraphish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id]).where(TableOfContent.arel_table[:ordering].gt(@position))
    @subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
