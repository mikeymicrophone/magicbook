class Chapter < ApplicationRecord
  belongs_to :edition
  has_one :book, :through => :edition
  has_many :sections
  has_many :paragraphs, :through => :sections
  has_many :citations, :through => :paragraphs
end
