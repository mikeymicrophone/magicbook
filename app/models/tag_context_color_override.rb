class TagContextColorOverride < ApplicationRecord
  belongs_to :mage
  belongs_to :tag_context

  validates :color, presence: true, format: { with: HexColor::STORED }
  validates :tag_context_id, uniqueness: { scope: :mage_id }

  before_validation :normalize_color

  private

  def normalize_color
    self.color = HexColor.normalize(color) || color
  end
end
