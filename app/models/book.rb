class Book < ApplicationRecord
  has_many :table_of_contents
  has_many :editions, -> { where 'table_of_contents.chapter_id' => nil }, :through => :table_of_contents
  has_many :chapters, -> { where 'table_of_contents.section_id' => nil }, :through => :table_of_contents
  has_many :sections, -> { where 'table_of_contents.paragraph_id' => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where 'table_of_contents.citation_id' => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  mount_uploader :pdf, PdfUploader
  
  def current_edition
    editions.recent.published.recent.first
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
  
  def self.featured
    find(ENV['DEFAULT_BOOK_IDS'])
  end
  
  def to_param
    "#{id}-#{permalink}"
  end

  def permalink
    title.gsub(/[^a-z0-9]+/i, '-')
  end
end
