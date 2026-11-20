# DEFAULT_BOOK_IDS holds the featured book's UUID, so specs create the book and point it there.
module FeaturedBook
  def create_featured_book!(**attributes)
    book = Book.create!({ title: "Featured book", version: "1.0.0" }.merge(attributes))
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("DEFAULT_BOOK_IDS").and_return(book.id)
    book
  end
end

RSpec.configure do |config|
  config.include FeaturedBook
end
