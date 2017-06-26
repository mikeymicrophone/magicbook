class PurchasedBooksController < ApplicationController
  def index
    @purchased_books = PurchasedBook.all
  end
end
