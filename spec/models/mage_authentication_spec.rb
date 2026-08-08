require 'rails_helper'

RSpec.describe Mage, type: :model do
  describe '.from_google_oauth!' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'google-subject-123',
        info: { email: 'reader@example.test', email_verified: true, first_name: 'Reader', last_name: 'Mage' }
      )
    end

    it 'creates one Mage and links the verified Google identity' do
      mage = described_class.from_google_oauth!(auth)

      expect(mage).to be_persisted
      expect(mage).to be_confirmed
      expect(mage.email).to eq('reader@example.test')
      expect(mage.identifiers.find_by(provider: 'google_oauth2', uid: 'google-subject-123')).to be_present
    end

    it 'reuses the same Mage when Google signs in again' do
      first = described_class.from_google_oauth!(auth)

      expect { described_class.from_google_oauth!(auth) }.not_to change(described_class, :count)
      expect(described_class.from_google_oauth!(auth)).to eq(first)
    end

    it 'rejects an OAuth response without a verified email' do
      auth.info.email_verified = false

      expect { described_class.from_google_oauth!(auth) }.to raise_error(ArgumentError, /verified email/)
    end
  end

  describe 'magic links' do
    let(:mage) { Fabricate(:mage) }

    it 'issues a one-time link token without storing the token itself' do
      token = mage.issue_magic_link!

      expect(token).to be_present
      expect(mage.reload.magic_link_token_digest).to eq(Digest::SHA256.hexdigest(token))
      expect(described_class.consume_magic_link(token)).to eq(mage)
      expect(described_class.consume_magic_link(token)).to be_nil
    end

    it 'does not consume an expired token' do
      token = mage.issue_magic_link!
      mage.update_column(:magic_link_sent_at, described_class::MAGIC_LINK_LIFETIME.ago - 1.second)

      expect(described_class.consume_magic_link(token)).to be_nil
    end
  end

  describe '#ensure_webauthn_user_handle!' do
    it 'persists a stable WebAuthn user handle' do
      mage = Fabricate(:mage)

      expect { mage.ensure_webauthn_user_handle! }.to change { mage.reload.webauthn_user_handle }.from(nil)
      expect(mage.ensure_webauthn_user_handle!).to eq(mage.webauthn_user_handle)
    end
  end
end
