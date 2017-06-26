class Edition < ApplicationRecord
  belongs_to :book
  
  mount_uploader :pdf, PdfUploader
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
end
