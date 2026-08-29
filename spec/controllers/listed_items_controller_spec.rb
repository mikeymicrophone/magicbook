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
  let!(:featured_book) { Book.create!(id: 1, title: 'Featured book', version: '1.0.0') }

  before { sign_in mage }

  it 'renders the new item form in the matching Turbo Frame' do
    get :new, params: { list_id: list.id }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("<turbo-frame id=\"#{ActionView::RecordIdentifier.dom_id(list, :new_item_adder_for)}\"")
    expect(response.body).to include('form_for_listed_item')
  end

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
