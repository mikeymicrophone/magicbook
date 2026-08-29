class Tag < ApplicationRecord
  KINDS = %w[system user].freeze

  belongs_to :tag_context, optional: true
  has_many :taggings, dependent: :restrict_with_error

  validates :slug, :name, presence: true
  validates :slug, uniqueness: { scope: :tag_context_id }
  validates :kind, inclusion: { in: KINDS }

  before_validation :assign_slug, on: :create
  before_update :prevent_system_rename
  before_destroy :prevent_system_destruction, prepend: true

  def system?
    kind == "system"
  end

  private

  def assign_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end

  def prevent_system_rename
    return unless system? && (will_save_change_to_name? || will_save_change_to_slug?)

    errors.add(:base, "System tags cannot be renamed")
    throw :abort
  end

  def prevent_system_destruction
    return unless system?

    errors.add(:base, "System tags cannot be destroyed")
    throw :abort
  end
end
