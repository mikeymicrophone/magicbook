require 'rails_helper'

RSpec.describe 'Magician registrations', type: :request do
  before do
    host! 'localhost'
    Book.create!(id: 1, title: 'Featured book', version: '1.0.0')
    ActionMailer::Base.deliveries.clear
  end

  it 'lets a new reader sign up and sends confirmation instructions' do
    get new_magician_registration_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Sign up')

    expect do
      post magician_registration_path, params: {
        magician: {
          email: 'new-reader@example.test',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end.to change(Magician, :count).by(1)
      .and change(ActionMailer::Base.deliveries, :count).by(1)

    magician = Magician.find_by!(email: 'new-reader@example.test')
    expect(magician).not_to be_confirmed
    expect(ActionMailer::Base.deliveries.last.to).to eq(['new-reader@example.test'])
  end
end
