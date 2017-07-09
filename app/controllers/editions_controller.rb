class EditionsController < ApplicationController
  def index
    @editions = Edition.all
  end
  
  def new
    @edition = Edition.new
  end
  
  def create
    @edition = Edition.create edition_params
    @edition.locate params
  end
  
  def append
    @edition = Edition.find params[:editionId]
    @edition.book = Book.find params[:bookId]
  end
  
  def edition_params
    params.require(:edition).permit(:major, :minor, :patch)
  end
end
