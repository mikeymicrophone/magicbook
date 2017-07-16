class ParagraphsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @paragraph = Paragraph.create paragraph_params
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
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
