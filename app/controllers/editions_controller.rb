class EditionsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @editions = Edition.all
  end
  
  def new
    @edition = Edition.new
    @previous_edition = Edition.where(:id => params[:previous_edition_id]).take
    @book = Book.find params[:book_id]
  end
  
  def create
    @previous_edition = Edition.where(:id => params[:previous_edition]).take
    @book = Book.find params[:book]
    @edition = Edition.create edition_params
    @edition.locate params
    @edition.copy_contents_from @previous_edition, @book if @previous_edition
  end
  
  def append
    @edition = Edition.find params[:editionId]
    @edition.book = Book.find params[:bookId]
  end
  
  def release
    @edition = Edition.find params[:id]
    @edition.update_attribute :release, Time.now
    head :ok
  end
  
  def edition_params
    params.require(:edition).permit(:major, :minor, :patch)
  end
end
