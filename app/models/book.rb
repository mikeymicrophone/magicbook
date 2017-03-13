class Book < ApplicationRecord
  mount_uploader :pdf, PdfUploader
end
