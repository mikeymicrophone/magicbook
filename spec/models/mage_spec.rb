require 'rails_helper'

RSpec.describe Mage, type: :model do
  describe 'account shape' do
    it 'normalizes username and display name' do
      mage = Fabricate.build(:mage, username: '  Mixed_Case1 ', display_name: "  Morgan\u0007 Le Fay \n")

      expect(mage.username).to eq('mixed_case1')
      expect(mage.display_name).to eq('Morgan Le Fay')
      expect(Fabricate.build(:mage, username: ' ', display_name: ' ').attributes.values_at('username', 'display_name')).to eq([nil, nil])
    end

    it 'allows a missing username and display name' do
      expect(Fabricate.build(:mage, username: nil, display_name: nil)).to be_valid
    end

    it 'requires usernames of 3 to 24 characters' do
      expect(Fabricate.build(:mage, username: 'ab')).not_to be_valid
      expect(Fabricate.build(:mage, username: 'abc')).to be_valid
      expect(Fabricate.build(:mage, username: 'a' * 24)).to be_valid
      expect(Fabricate.build(:mage, username: 'a' * 25)).not_to be_valid
    end

    it 'restricts username characters' do
      mage = Fabricate.build(:mage, username: 'no spaces!')

      expect(mage).not_to be_valid
      expect(mage.errors[:username]).to include('can only contain letters, numbers, and underscores')
      expect(Fabricate.build(:mage, username: 'ok_name_9')).to be_valid
    end

    it 'excludes reserved usernames' do
      described_class::RESERVED_USERNAMES.each do |name|
        expect(Fabricate.build(:mage, username: name.upcase)).not_to be_valid
      end
      expect(described_class::RESERVED_USERNAMES).to include('magicbook', 'wayswemage', 'rizz', 'micharisma')
    end

    it 'enforces case-insensitive uniqueness in the model' do
      Fabricate(:mage, username: 'morgan_taken')

      expect(Fabricate.build(:mage, username: 'Morgan_Taken')).not_to be_valid
    end

    it 'enforces case-insensitive uniqueness in the database' do
      Fabricate(:mage, username: 'morgan_taken')
      other = Fabricate(:mage, username: 'morgan_other')

      expect { other.update_columns(username: 'MORGAN_TAKEN') }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows many mages without a username' do
      Fabricate(:mage, username: nil)

      expect { Fabricate(:mage, username: nil) }.not_to raise_error
    end

    it 'builds a handle only when a username exists' do
      expect(Fabricate.build(:mage, username: 'morgan_taken').handle).to eq('@morgan_taken')
      expect(Fabricate.build(:mage, username: nil).handle).to be_nil
    end

    it 'caps display name at 60 characters' do
      expect(Fabricate.build(:mage, display_name: 'a' * 60)).to be_valid
      expect(Fabricate.build(:mage, display_name: 'a' * 61)).not_to be_valid
    end
  end

  describe '.from_google_oauth! display name' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'google-subject-456',
        info: { email: 'morgan@example.test', email_verified: true, first_name: 'Morgan', last_name: 'Le Fay', name: "Morgan\tLe Fay #{'x' * 80}" }
      )
    end

    it 'fills the display name of a new Mage from the Google name, truncated to 60 characters' do
      mage = described_class.from_google_oauth!(auth)

      expect(mage.display_name).to eq("MorganLe Fay #{'x' * 47}")
      expect(mage.display_name.length).to eq(60)
    end

    it 'fills a blank display name on an existing Mage but keeps a chosen one' do
      blank = Fabricate(:mage, email: 'morgan@example.test', display_name: nil)
      expect(described_class.from_google_oauth!(auth).display_name).to be_present
      expect(blank.reload.display_name).to be_present

      chosen = Fabricate(:mage, email: 'chosen@example.test', display_name: 'Chosen One')
      auth.uid = 'google-subject-789'
      auth.info.email = 'chosen@example.test'
      described_class.from_google_oauth!(auth)

      expect(chosen.reload.display_name).to eq('Chosen One')
    end

    it 'leaves the display name blank when Google sends no name' do
      auth.info = { email: 'morgan@example.test', email_verified: true }

      expect(described_class.from_google_oauth!(auth).display_name).to be_nil
    end
  end
end
