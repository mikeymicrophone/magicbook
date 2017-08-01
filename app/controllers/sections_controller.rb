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
    @edition = Edition.find params[:edition]
    @book = Book.find params[:book]
    
    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch + 1
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book
    
    @new_section = Section.create section_params
    
    @new_edition.table_of_contents.each do |table_of_content|
      if table_of_content.section_id == @section.id
        table_of_content.update_attribute :section_id, @new_section.id
      end
    end
    redirect_to edit_book_path @book
  end
  
  def promote
    @table_of_content = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :section_id => params[:id]).first
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = TableOfContent.sectionish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => @table_of_content.chapter_id, :ordering => @previous_position.pred).first
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def destroy
    @section = Section.find params[:id]
    @chapter = Chapter.find params[:chapter_id]
    @edition = Edition.find params[:edition_id]
    @book = Book.find params[:book_id]
    
    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch + 1
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book, :exclude => @section
    redirect_to edit_book_path @book
  end
  
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end
