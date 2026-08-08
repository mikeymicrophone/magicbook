require 'rails_helper'

RSpec.describe Mage, type: :model do
  it 'creates an access account that must choose a password' do
    mage = described_class.create_access_account!('Reader@Example.test')

    expect(mage).to be_persisted
    expect(mage.email).to eq('reader@example.test')
    expect(mage).to be_must_set_password
  end

end
