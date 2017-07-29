class ParagraphsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @paragraph = Paragraph.create paragraph_params
    @section = Section.find params[:section]
    @paragraph.locate params
  end
  
  def append
    @paragraph = Paragraph.find params[:id]
    @paragraph.section = Section.find params[:id]
    @paragraph.chapter = Chapter.find params[:chapterId]
    @paragraph.edition = Edition.find params[:editionId]
    @paragraph.book = Book.find params[:bookId]
    @citation = @paragraph.citations.new
  end
  
  def delay
    # @table_of_content = TableOfContent.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:chapter_id], :section_id => params[:section_id], :paragraph_id => params[:id], :citation_id => nil)
    @paragraph = Paragraph.find params[:id]
    @edition = Edition.find params[:edition_id]
    @book = Book.find params[:book_id]
    
    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch + 1
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book, :delay => @paragraph
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
    redirect_to edit_book_path @book
  end
  
  def destroy
    @paragraph = Paragraph.find params[:id]
    @section = Section.find params[:section_id]
    @chapter = Chapter.find params[:chapter_id]
    @edition = Edition.find params[:edition_id]
    @book = Book.find params[:book_id]
    
    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch + 1
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book, :exclude => @paragraph
    redirect_to edit_book_path @book
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
