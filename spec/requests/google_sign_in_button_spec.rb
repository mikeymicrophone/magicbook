require 'rails_helper'

RSpec.describe 'Google sign-in button', type: :request do
  before do
    allow(Book).to receive(:featured).and_return(Fabricate(:book, title: 'Ways We Mage'))
  end

  it 'renders both logos in a POST button on the sign-in page' do
    allow(Mage).to receive(:google_oauth_configured?).and_return(true)
    get new_mage_session_path
    expect(response).to have_http_status(:ok)

    form = Nokogiri::HTML(response.body).at_css('form.google-sign-in-form')
    expect(form['method']).to eq('post')
    expect(form['action']).to eq(mage_google_oauth2_omniauth_authorize_path)
    expect(form['data-turbo']).to eq('false')
    expect(form.css('img').map { |image| image['src'] }).to eq(%w[/google-g.png /google-sign-in-site.png])
    expect(form.text).to include('Continue with Google')
  end

  ['/lists?view=popular', 'https://example.com/collect'].each do |destination|
    it "accepts only a local return destination: #{destination}" do
      mage = Fabricate(:mage, confirmed_at: Time.current)
      allow(Mage).to receive(:from_google_oauth!).and_return(mage)
      Rails.application.env_config['omniauth.auth'] = {}
      Rails.application.env_config['omniauth.params'] = { 'return_to' => destination }

      get mage_google_oauth2_omniauth_callback_path

      expected = destination.start_with?('/') ? destination : books_path
      expect(response).to redirect_to(expected)
    ensure
      Rails.application.env_config.delete('omniauth.auth')
      Rails.application.env_config.delete('omniauth.params')
    end
  end
end
