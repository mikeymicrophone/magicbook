require 'rails_helper'

RSpec.describe ListedItemsController, type: :controller do
  render_views

  let!(:mage) do
    Mage.create!(
      email: 'listed-items-controller@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(mage: mage, name: 'Controller Turbo list') }

  before { sign_in mage }

  it 'creates an item with a Turbo Stream response that refreshes the list and add form' do
    expect do
      post :create,
           params: { list_id: list.id, listed_item: { designation: 'Turbo item', privacy: 'draft' } },
           format: :turbo_stream
    end.to change(ListedItem, :count).by(1)

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(list, :listed_items_in)}\"")
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(list, :new_item_adder_for)}\"")
  end
end
