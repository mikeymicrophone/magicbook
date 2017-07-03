class Edition < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :chapters, -> { where :section_id => nil }, :through => :table_of_contents
  has_many :sections, -> { where :paragraph_id => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where :citation_id => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  attr_accessor :book
  
  mount_uploader :pdf, PdfUploader
  
  scope :recent, lambda { order(:major => :desc, :minor => :desc, :patch => :desc) }
  scope :published, lambda { where Edition.arel_table[:release].lt DateTime.now }
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
end
