require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  let!(:book) { Book.create!(id: 1, title: 'Featured book', version: '1.0.0') }
  let!(:mage) do
    Mage.create!(
      email: 'owner@example.test',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:purchase) { Purchase.create!(email: mage.email, mage: mage, ramp: true, book_id: book.id) }

  before { sign_in mage }

  it 'creates a Mage-backed invitation for a recipient' do
    expect do
      post :submit, params: { purchase_id: purchase.id, email_1: 'reader@example.test', message: 'Enjoy!' }
    end.to change(Invitation, :count).by(1)
      .and change(Mage, :count).by(1)

    invitation = Invitation.last
    expect(invitation.mage.email).to eq('reader@example.test')
    expect(invitation.inviter).to eq(mage)
    expect(response).to redirect_to(invite_invitations_path(purchase_id: purchase))
  end
end
