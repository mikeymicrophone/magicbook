require 'rails_helper'

RSpec.describe Invitation, type: :model do
  let!(:book) { Book.create!(id: 1, title: 'Featured book', version: '1.0.0') }
  let!(:inviter) do
    Mage.create!(
      email: 'owner@example.test',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end
  let!(:purchase) { Purchase.create!(email: inviter.email, mage: inviter, ramp: true, book_id: book.id) }

  it 'grants the recipient access to the purchase books' do
    recipient = Mage.create_access_account!('reader@example.test')
    invitation = described_class.create!(purchase: purchase, mage: recipient, inviter: inviter)

    expect(invitation.books).to contain_exactly(book)
    expect(recipient.accessible_books).to contain_exactly(book)
  end

  it 'allows each purchase to be shared with at most four recipients' do
    4.times do |index|
      recipient = Mage.create_access_account!("reader-#{index}@example.test")
      described_class.create!(purchase: purchase, mage: recipient, inviter: inviter)
    end

    recipient = Mage.create_access_account!('fifth-reader@example.test')
    invitation = described_class.new(purchase: purchase, mage: recipient, inviter: inviter)

    expect(invitation).not_to be_valid
    expect(invitation.errors.full_messages).to include('All four invitations for this purchase have already been used.')
  end
end
