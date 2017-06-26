class Edition < ApplicationRecord
  belongs_to :book
  
  mount_uploader :pdf, PdfUploader
end
