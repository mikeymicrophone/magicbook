require 'rails_helper'

RSpec.describe 'Mage registrations', type: :request do
  before do
    host! 'localhost'
    Book.create!(id: 1, title: 'Featured book', version: '1.0.0')
    ActionMailer::Base.deliveries.clear
  end

  it 'lets a new reader sign up and sends confirmation instructions' do
    get new_mage_registration_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Sign up')

    expect do
      post mage_registration_path, params: {
        mage: {
          email: 'new-reader@example.test',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end.to change(Mage, :count).by(1)
      .and change(ActionMailer::Base.deliveries, :count).by(1)

    mage = Mage.find_by!(email: 'new-reader@example.test')
    expect(mage).not_to be_confirmed
    expect(ActionMailer::Base.deliveries.last.to).to eq(['new-reader@example.test'])
  end

  it 'renders one Mage sign-in form' do
    get new_mage_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Mage Log in')
    expect(response.body).not_to include('Muggle Log in')
  end
end
