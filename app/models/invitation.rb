class Invitation < ApplicationRecord
  belongs_to :purchase
  belongs_to :mage
  belongs_to :inviter, class_name: 'Mage'

  validates :mage_id, uniqueness: { scope: :purchase_id }
  validate :purchase_has_remaining_invitations, on: :create
  validate :purchase_is_fresh, on: :create

  scope :recent, -> { order(created_at: :desc) }

  delegate :books, to: :purchase

  private

  def purchase_has_remaining_invitations
    errors.add(:base, 'All four invitations for this purchase have already been used.') if purchase.invitations.count >= 4
  end

  def purchase_is_fresh
    errors.add(:base, 'This purchase was made more than three days ago.') unless purchase.fresh?
  end
end
