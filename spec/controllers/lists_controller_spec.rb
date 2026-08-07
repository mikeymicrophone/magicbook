require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  render_views

  let!(:scribe) do
    Scribe.create!(
      email: 'list-review-scribe@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:magician) do
    Magician.create!(
      email: 'list-review-owner@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(magician: magician, name: 'Turbo review list', privacy: 'unreviewed') }

  before { sign_in scribe }

  it 'approves a list with a Turbo Stream response that removes it from review' do
    put :approve, params: { id: list.id }, format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(list, :approval_interface_for)}\"")
    expect(list.reload.privacy).to eq('published')
  end

  it 'updates a pin without leaving the current page for a Turbo Stream request' do
    put :update, params: { id: list.id, list: { pin: 'examplary' } }, format: :turbo_stream

    expect(response).to have_http_status(:no_content)
    expect(list.reload.pin).to eq('examplary')
  end
end
