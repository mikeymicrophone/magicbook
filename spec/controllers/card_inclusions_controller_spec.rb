require 'rails_helper'

RSpec.describe CardInclusionsController, type: :controller do
  render_views

  let!(:magician) do
    Magician.create!(
      email: 'card-inclusion-owner@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(magician: magician, name: 'Card inclusion list') }
  let!(:listed_item) { ListedItem.create!(list: list, designation: 'A listed card') }
  let!(:card) { Card.create!(name: 'Turbo Test Card', image_url: 'https://example.test/turbo-test-card.png') }

  before { sign_in magician }

  it 'includes a known card with a Turbo Stream response that refreshes the listed item' do
    expect do
      post :create,
           params: { card_inclusion: { card_name: card.name, piece_id: listed_item.id, piece_type: 'ListedItem' } },
           format: :turbo_stream
    end.to change(CardInclusion, :count).by(1)

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(listed_item)}\"")
  end
end
