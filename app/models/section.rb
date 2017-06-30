class Section < ApplicationRecord
  belongs_to :chapter
  has_one :edition, :through => :chapter
  has_one :book, :through => :edition
  has_many :paragraphs
end
