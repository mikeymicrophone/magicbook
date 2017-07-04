class Section < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :editions, :through => :table_of_contents
  has_many :chapters, :through => :table_of_contents
  has_many :paragraphs, -> { where 'table_of_contents.citation_id' => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  attr_accessor :chapter, :edition, :book
end
