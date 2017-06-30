class Edition < ApplicationRecord
  belongs_to :book
  has_many :chapters
  has_many :sections, :through => :chapters
  has_many :paragraphs, :through => :sections
  
  mount_uploader :pdf, PdfUploader
  
  scope :recent, lambda { order(:major => :desc, :minor => :desc, :patch => :desc) }
  scope :published, lambda { where Edition.arel_table[:release].lt DateTime.now }
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
end
