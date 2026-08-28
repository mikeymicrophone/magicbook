class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
  belongs_to :mage, optional: true

  validates :tag_id, uniqueness: { scope: [:taggable_type, :taggable_id] }
end
