class Purchase < ApplicationRecord
  has_many :purchased_books
  has_many :books, :through => :purchased_books
end
