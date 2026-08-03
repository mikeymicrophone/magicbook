class TableOfContent < ApplicationRecord
  class ReorderError < StandardError; end

  belongs_to :book, :optional => true
  belongs_to :edition, :optional => true
  belongs_to :chapter, :optional => true
  belongs_to :section, :optional => true
  belongs_to :paragraph, :optional => true
  belongs_to :citation, :optional => true
  
  before_create :locate, :sequence
  
  scope :editionish, lambda { where(:chapter_id => nil) }
  scope :chapterish, lambda { where.not(:chapter_id => nil).where(:section_id => nil) }
  scope :sectionish, lambda { where.not(:section_id => nil).where(:paragraph_id => nil) }
  scope :paragraphish, lambda { where.not(:paragraph_id => nil).where(:citation_id => nil) }
  scope :citationish, lambda { where.not(:citation_id => nil) }

  scope :in_edition, lambda { |edition| where :edition_id => edition.id }
  scope :in_chapter, lambda { |chapter| where :chapter_id => chapter.id }
  scope :in_section, lambda { |section| where :section_id => section.id }
  scope :in_paragraph, lambda { |paragraph| where :paragraph_id => paragraph.id }
  
  scope :ordered, lambda { order :ordering }
  
  def locate
    self.paragraph ||= citation&.paragraph
    self.section ||= citation&.section || paragraph&.section
    self.chapter ||= citation&.chapter || paragraph&.chapter || section&.chapter
    self.edition ||= citation&.edition || paragraph&.edition || section&.edition || chapter&.edition
    self.book ||= citation&.book || paragraph&.book || section&.book || chapter&.book || edition&.book
  end
  
  def sequence
    if ordering.blank?
      if citation_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id, :section_id => section_id, :paragraph_id => paragraph_id).where.not(:citation_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif paragraph_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id, :section_id => section_id).where.not(:paragraph_id => nil).where(:citation_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif section_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id).where.not(:section_id => nil).where(:paragraph_id => nil).order(:ordering).last&.ordering.to_i + 1
      elsif chapter_id.present?
        self.ordering = self.class.where(:book_id => book_id, :edition_id => edition_id).where.not(:chapter_id => nil).where(:section_id => nil).order(:ordering).last&.ordering.to_i + 1
      end
    else
      
    end
  end
  
  def content
    citation || paragraph || section || chapter || edition
  end
  
  def content_identifier
    (content.class.name.underscore + '_id').intern
  end
  
  def content_hierarchy
    {
      :book_id => :edition_id,
      :edition_id => :chapter_id,
      :chapter_id => :section_id,
      :section_id => :paragraph_id,
      :paragraph_id => :citation_id
    }
  end
  
  def child_identifier
    content_hierarchy[content_identifier]
  end
  
  def content_attributes
    {:book_id => book_id, :edition_id => edition_id, :chapter_id => chapter_id, :section_id => section_id, :paragraph_id => paragraph_id, :citation_id => citation_id}
  end
  
  def subsequent
    self.class.where.not(content_identifier => nil).where(content_attributes.except content_identifier).where TableOfContent.arel_table[:ordering].gt(ordering)
  end
  
  def succeeding
    subsequent.ordered.first
  end
  
  def prior
    self.class.where.not(content_identifier => nil).where(content_attributes.except content_identifier).where TableOfContent.arel_table[:ordering].lt(ordering)
  end
  
  def previous
    prior.ordered.last
  end
  
  def parent
    self.class.where(content_attributes.except content_identifier).find_by content_identifier => nil
  end
  
  def children
    self.class.where(content_attributes.except child_identifier).where.not(child_identifier => nil)
  end
  
  def last_child
    children.ordered.last
  end

  # Reordering is performed against locked sibling rows so two editors cannot
  # silently assign the same position or overwrite each other's swap.
  def promote!
    self.class.transaction do
      current = locked_siblings.find(id)
      previous = locked_siblings.where(TableOfContent.arel_table[:ordering].lt(current.ordering)).ordered.last
      raise ReorderError, 'There is no previous item to promote' unless previous

      current_ordering = current.ordering
      current.update!(ordering: previous.ordering)
      previous.update!(ordering: current_ordering)

      previous
    end
  end

  # Move this node and every contained descendent to the next parent at the
  # same level (section -> next chapter, paragraph -> next section, etc.).
  def delay!
    self.class.transaction do
      current = locked_siblings.find(id)
      source_siblings = locked_siblings.to_a
      parent = current.parent
      raise ReorderError, 'There is no parent to move from' unless parent

      parent.lock!
      succeeding_parent = parent.succeeding
      raise ReorderError, 'There is no following parent to move to' unless succeeding_parent

      succeeding_parent.lock!
      destination_parent_attribute = current.content_hierarchy.key(current.content_identifier)
      destination_value = succeeding_parent.public_send(destination_parent_attribute)
      last_destination_ordering = succeeding_parent.children.lock.ordered.last&.ordering.to_i
      subsequent_source_siblings = source_siblings.select { |sibling| sibling.ordering > current.ordering }

      current.contained.lock.find_each do |contained|
        contained.update!(destination_parent_attribute => destination_value)
      end
      current.update!(ordering: last_destination_ordering + 1)
      subsequent_source_siblings.each { |sibling| sibling.update!(ordering: sibling.ordering - 1) }
    end
  end
  
  def descendent_identifiers
    identifiers = [child_identifier]
    while content_hierarchy[identifiers.last]
      identifiers << content_hierarchy[identifiers.last]
    end
    identifiers
  end
  
  def contained
    self.class.where(content_attributes.except *descendent_identifiers)
  end
  
  def descendents
    contained.where.not :id => id
  end

  private

  def sibling_scope
    self.class.where.not(content_identifier => nil).where(content_attributes.except(content_identifier))
  end

  def locked_siblings
    sibling_scope.lock
  end
end
