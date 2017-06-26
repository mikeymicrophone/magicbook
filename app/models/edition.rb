class Edition < ApplicationRecord
  belongs_to :book
  
  mount_uploader :pdf, PdfUploader
  
  scope :recent, lambda { order(:major => :desc, :minor => :desc, :patch => :desc) }
  scope :published, lambda { where Edition.arel_table[:release].lt DateTime.now }
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
end
