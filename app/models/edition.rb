class Edition < ApplicationRecord
  has_many :table_of_contents
  has_many :books, :through => :table_of_contents
  has_many :chapters, -> { where 'table_of_contents.section_id' => nil }, :through => :table_of_contents
  has_many :sections, -> { where 'table_of_contents.paragraph_id' => nil }, :through => :table_of_contents
  has_many :paragraphs, -> { where 'table_of_contents.citation_id' => nil }, :through => :table_of_contents
  has_many :citations, :through => :table_of_contents
  
  attr_accessor :book
  
  mount_uploader :pdf, PdfUploader
  
  scope :recent, lambda { order(:major => :desc, :minor => :desc, :patch => :desc) }
  scope :published, lambda { where Edition.arel_table[:release].lt DateTime.now }
  
  def copy_contents_from edition, book, options = {}
    excluded_parameters = ""
    if options[:exclude]
      excluded = options[:exclude]
      case excluded
      when Paragraph
        excluded_parameters = "paragraph_id is distinct from #{excluded.id}"
      end
    end
    edition.table_of_contents.where(:book_id => book.id).where(excluded_parameters).each do |table_of_content|
      attrs = table_of_content.attributes.except 'edition_id', 'id'
      next if attrs['chapter_id'].blank?
      table_of_contents.create attrs
    end
  end
  
  def version
    "#{major}.#{minor}.#{patch}"
  end
  
  def locate params
    @book = Book.find params[:book]
    table_of_contents.create
  end
end
