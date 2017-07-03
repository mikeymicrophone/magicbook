class SectionsController < ApplicationController
  def append
    @section = Section.find params[:id]
    @paragraph = @section.paragraphs.new
  end
end
