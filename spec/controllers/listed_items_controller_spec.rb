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
  let!(:featured_book) { create_featured_book! }

  before { sign_in mage }

  it 'renders the new item form in the matching Turbo Frame' do
    get :new, params: { list_id: list.to_param }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("<turbo-frame id=\"#{ActionView::RecordIdentifier.dom_id(list, :new_item_adder_for)}\"")
    expect(response.body).to include('form_for_listed_item')
  end

  it 'creates an item with a Turbo Stream response that refreshes the list and add form' do
    expect do
      post :create,
           params: { list_id: list.to_param, listed_item: { designation: 'Turbo item', privacy: 'draft' } },
           format: :turbo_stream
    end.to change(ListedItem, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(ListedItem.order(:created_at).last.list).to eq(list)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(list, :listed_items_in)}\"")
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(list, :new_item_adder_for)}\"")
  end

  context 'when signed out' do
    let!(:notify_list) { List.create!(mage: mage, name: 'Suggestions list', privacy: :published, suggestability: :notify) }

    before { sign_out mage }

    it 'accepts an anonymous suggestion with a slugged list param without crashing' do
      expect do
        post :create,
             params: { list_id: notify_list.to_param, listed_item: { designation: 'Suggested item', privacy: 'suggested' } },
             format: :turbo_stream
      end.to change(ListedItem, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      created_item = ListedItem.order(:created_at).last
      expect(created_item.list).to eq(notify_list)
      expect(created_item.privacy).to eq('suggested')
      expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(notify_list, :listed_items_in)}\"")
    end
  end
end
