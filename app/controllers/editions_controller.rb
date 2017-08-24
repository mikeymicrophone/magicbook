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
    @edition = Edition.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def release
    @edition = Edition.find params[:id]
    @edition.update_attribute :release, Time.now
    @book = Book.find params[:book_id]
    @book.update_attribute :version, @edition.version

    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor.next, :patch => 0
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book
    redirect_to edit_book_path @book
  end
  
  def freeze
    @edition = Edition.find params[:id]
    @book = Book.find params[:book_id]

    @new_edition = Edition.create :major => @edition.major, :minor => @edition.minor, :patch => @edition.patch.next
    TableOfContent.create :book => @book, :edition => @new_edition
    @new_edition.copy_contents_from @edition, @book
    redirect_to edit_book_path @book
  end
  
  def edition_params
    params.require(:edition).permit(:major, :minor, :patch)
  end
end
