class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @books = if current_mage&.admin?
      Book.all
    elsif current_mage
      current_mage.accessible_books
    else
      Book.all
    end
  end

  def show
  end

  def new
    @book = Book.new
  end

  def edit
    @edition = @book.editions.last
    @edition_table_of_content = TableOfContent.editionish.find_by :book_id => @book, :edition_id => @edition
  end

  def create
    @book = Book.new book_params

    if @book.save
      redirect_to @book, notice: 'Book was successfully created.'
    else
      render :new
    end
  end

  def update
    if @book.update book_params
      redirect_to @book, notice: 'Book was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: 'Book destroyed.'
  end

  def set_book
    @book = Book.find params[:id]
  end

  def book_params
    params.require(:book).permit :title, :version, :pdf, :author, :price_cents
  end
end
