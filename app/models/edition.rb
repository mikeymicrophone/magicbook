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
    delayed_content_type = nil
    if options[:exclude]
      excluded = options[:exclude]
      case excluded
      when Paragraph
        excluded_parameters = "paragraph_id is distinct from #{excluded.id}"
      when Section
        excluded_parameters = "section_id is distinct from #{excluded.id}"
      end
    end
    if options[:delay]
      delayed = options[:delay]
      case delayed
      when Paragraph
        delayed_content_type = 'paragraph_id'
        delayed_content_id = delayed.id
        delayed_parent_type = 'section_id'
        delayed_parent_scope = :sectionish
      end
    end
    edition.table_of_contents.where(:book_id => book.id).where(excluded_parameters).each do |table_of_content|
      attrs = table_of_content.attributes.except 'id', 'created_at', 'updated_at', 'flags'
      next if attrs['chapter_id'].blank?
      if delayed_content_type
        if attrs[delayed_content_type] == delayed_content_id
          query = attrs.except delayed_content_type, 'ordering'
          parent = TableOfContent.send(delayed_parent_scope).where(query).first
          query.delete delayed_parent_type
          query['ordering'] = parent.ordering + 1
          subsequent_parent = TableOfContent.send(delayed_parent_scope).where(query).first
          attrs[delayed_parent_type] = subsequent_parent.send(delayed_parent_type)
          attrs['ordering'] = nil
        end
      end
      table_of_contents.create attrs.except('edition_id')
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
