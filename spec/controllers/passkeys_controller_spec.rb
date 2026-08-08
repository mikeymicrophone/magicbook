require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe PasskeysController, type: :controller do
  let(:mage) { Fabricate(:mage) }

  describe 'POST #registration_options' do
    it 'requires a signed-in Mage' do
      post :registration_options, format: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns discoverable, user-verified credential options' do
      sign_in mage

      post :registration_options, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('challenge', 'user')
      expect(mage.reload.webauthn_user_handle).to be_present
    end

    it 'verifies and stores a real WebAuthn registration response' do
      sign_in mage
      post :registration_options, format: :json
      options = JSON.parse(response.body)
      client = WebAuthn::FakeClient.new('http://localhost:3000')
      raw_credential = client.create(
        challenge: options.fetch('challenge'),
        rp_id: options.fetch('rp').fetch('id'),
        user_verified: true
      )

      expect do
        post :register, params: { credential: raw_credential }, format: :json
      end.to change(Passkey, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(mage.passkeys.last.transports).to eq(['internal'])
    end
  end

  describe 'POST #authenticate' do
    it 'completes a real passwordless WebAuthn authentication ceremony' do
      sign_in mage
      client = WebAuthn::FakeClient.new('http://localhost:3000')

      post :registration_options, format: :json
      registration_options = JSON.parse(response.body)
      registration = client.create(
        challenge: registration_options.fetch('challenge'),
        rp_id: registration_options.fetch('rp').fetch('id'),
        user_verified: true
      )
      post :register, params: { credential: registration }, format: :json
      sign_out mage

      post :authentication_options, format: :json
      authentication_options = JSON.parse(response.body)
      assertion = client.get(
        challenge: authentication_options.fetch('challenge'),
        rp_id: authentication_options.fetch('rpId'),
        user_verified: true,
        sign_count: 1
      )

      post :authenticate, params: { credential: assertion }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('redirect_to' => books_path)
      expect(controller.current_mage).to eq(mage)
    end

    it 'verifies a stored public credential and signs in its Mage' do
      passkey = mage.passkeys.create!(external_id: 'credential-id', public_key: 'public-key', sign_count: 1)
      credential = instance_double(WebAuthn::PublicKeyCredentialWithAssertion, id: passkey.external_id, sign_count: 2)
      allow(WebAuthn::Credential).to receive(:from_get).and_return(credential)
      allow(credential).to receive(:verify).and_return(true)
      session[:passkey_authentication_challenge] = 'challenge'

      post :authenticate, params: { credential: { id: passkey.external_id } }, format: :json

      expect(response).to have_http_status(:ok)
      expect(credential).to have_received(:verify).with(
        'challenge', public_key: passkey.public_key, sign_count: 1, user_verification: true
      )
      expect(passkey.reload.sign_count).to eq(2)
      expect(controller.current_mage).to eq(mage)
    end
  end
end
