class TagContext < ApplicationRecord
  KINDS = %w[system user].freeze

  has_many :tags, dependent: :restrict_with_error
  has_many :tag_context_color_overrides, dependent: :destroy

  validates :slug, :name, presence: true
  validates :slug, uniqueness: true
  validates :kind, inclusion: { in: KINDS }
  validates :color, presence: true, format: { with: HexColor::STORED }

  before_validation :normalize_color
  before_destroy :prevent_system_destruction, prepend: true

  def system?
    kind == "system"
  end

  private

  def normalize_color
    self.color = color.blank? ? HexColor::DEFAULT : (HexColor.normalize(color) || color)
  end

  def prevent_system_destruction
    return unless system?

    errors.add(:base, "System tag contexts cannot be destroyed")
    throw :abort
  end
end
