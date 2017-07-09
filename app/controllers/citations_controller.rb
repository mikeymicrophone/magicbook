class CitationsController < ApplicationController
  def create
    @citation = Citation.create citation_params
    @citation.locate params
  end
  
  def citation_params
    params.require(:citation).permit(:source, :finding)
  end
end
