class Book < ApplicationRecord
  has_many :table_of_contents
  has_many :editions, -> { where :chapter_id => nil }, :through => :table_of_contents
  has_many :chapters, -> { where :section_id => nil }, :through => :table_of_contents
  has_many :sections, -> { where :paragraph_id => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where :citation_id => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  mount_uploader :pdf, PdfUploader
  
  def current_edition
    editions.recent.published.first
  end
  
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
