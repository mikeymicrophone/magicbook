class EditionsController < ApplicationController
  def index
    @editions = Edition.all
  end
  
  def new
    @edition = Edition.new
  end
  
  def create
    @edition = Edition.new edition_params
    @edition.book = Book.find(params[:book][:id])
    @edition.save
  end
  
  def append
    @edition = Edition.find params[:editionId]
    @edition.book = Book.find params[:bookId]
    @chapter = @edition.chapters.new
  end
  
  def edition_params
    params.require(:edition).permit(:major, :minor, :patch)
  end
end
