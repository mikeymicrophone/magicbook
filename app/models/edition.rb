class Edition < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :chapters, -> { where 'table_of_contents.section_id' => nil }, :through => :table_of_contents
  has_many :sections, -> { where 'table_of_contents.paragraph_id' => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where 'table_of_contents.citation_id' => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  attr_accessor :book
  
  before_create :locate
  
  mount_uploader :pdf, PdfUploader
  
  scope :recent, lambda { order(:major => :desc, :minor => :desc, :patch => :desc) }
  scope :published, lambda { where Edition.arel_table[:release].lt DateTime.now }
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
  
  def locate
    self.books = [book]
  end
end
