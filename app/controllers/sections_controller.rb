class SectionsController < ApplicationController
  def create
    @section = Section.create section_params
    @section.locate params
  end
  
  def append
    @section = Section.find params[:id]
    @paragraph = @section.paragraphs.new
  end
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end
