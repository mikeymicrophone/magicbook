class Chapter < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :editions, :through => :table_of_contents
  has_many :sections, -> { where :paragraph_id => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where :citation_id => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
end
