class CitationsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @citation = Citation.create citation_params
    @citation.locate params
  end
  
  def citation_params
    params.require(:citation).permit(:source, :finding)
  end
end
