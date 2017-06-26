class Book < ApplicationRecord
  has_many :editions
  mount_uploader :pdf, PdfUploader
  
  def major_version
    version.split('.').first.to_i
  end
  
  def minor_version
    version.split('.').second.to_i
  end
  
  def patch_version
    version.split('.').third.to_i
  end
end
