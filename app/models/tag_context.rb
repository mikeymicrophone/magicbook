class TagContext < ApplicationRecord
  KINDS = %w[system user].freeze

  has_many :tags, dependent: :restrict_with_error

  validates :slug, :name, presence: true
  validates :slug, uniqueness: true
  validates :kind, inclusion: { in: KINDS }

  before_destroy :prevent_system_destruction, prepend: true

  def system?
    kind == "system"
  end

  private

  def prevent_system_destruction
    return unless system?

    errors.add(:base, "System tag contexts cannot be destroyed")
    throw :abort
  end
end
