require 'rails_helper'
require Rails.root.join('db/migrate/20260828010000_migrate_legacy_accounts_to_mages').to_s

RSpec.describe MigrateLegacyAccountsToMages do
  let(:legacy_magicians) { migration_model(:magicians) }
  let(:legacy_scribes) { migration_model(:scribes) }
  let(:legacy_lists) { migration_model(:lists) }
  let(:legacy_identifiers) { migration_model(:identifiers) }

  it 'preserves legacy reader ownership and gives a legacy scribe Mage access' do
    email = 'author@example.test'
    magician = legacy_magicians.create!(
      email: email,
      encrypted_password: Mage.new(password: 'reader password').encrypted_password,
      confirmed_at: 1.day.ago
    )
    legacy_scribes.create!(
      email: email,
      encrypted_password: Mage.new(password: 'scribe password').encrypted_password,
      confirmed_at: 2.days.ago
    )
    existing_mage = Mage.create!(email: email, password: 'temporary password')
    list = legacy_lists.create!(name: 'Original list', magician_id: magician.id)
    identifier = legacy_identifiers.create!(provider: 'google_oauth2', uid: 'legacy-subject', magician_id: magician.id)

    described_class.new.up

    mage = Mage.find_by!(email: email)
    expect(mage).to eq(existing_mage)
    expect(mage).to be_admin
    expect(mage).to be_confirmed
    expect(mage).to be_valid_password('scribe password')
    expect(list.reload.mage_id).to eq(mage.id)
    expect(identifier.reload.mage_id).to eq(mage.id)
  end

  private

  def migration_model(table_name)
    Class.new(ApplicationRecord) do
      self.table_name = table_name
    end
  end
end
