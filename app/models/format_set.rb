class FormatSet < ApplicationRecord
  belongs_to :format
  belongs_to :card_set

  validates :card_set_id, uniqueness: { scope: :format_id }
  validates :legal_until, comparison: { greater_than: :legal_from }, if: -> { legal_from && legal_until }

  # A set is in the format from legal_from up to, but not including,
  # legal_until. A blank date leaves that end open, so a rotation is recorded
  # ahead of time by giving the departing sets a legal_until.
  scope :current, ->(on = Date.current) {
    where("format_sets.legal_from IS NULL OR format_sets.legal_from <= ?", on)
      .where("format_sets.legal_until IS NULL OR format_sets.legal_until > ?", on)
  }
end
