class SectionsController < ApplicationController
  def create
    @section = Section.create section_params
    @section.locate params
  end
  
  def append
    @section = Section.find params[:id]
    @section.chapter = Chapter.find params[:chapterId]
    @section.edition = Edition.find params[:editionId]
    @section.book = Book.find params[:bookId]
    @paragraph = @section.paragraphs.new
  end
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end