require "rails_helper"

RSpec.describe Format do
  it "relates a format to many card sets without duplicate inclusions" do
    format = Format.create!(code: "standard", name: "Standard")
    card_set = CardSet.create!(code: "TST", name: "Test Expansion", category: :premier)

    format.card_sets << card_set

    expect(format.card_sets).to contain_exactly(card_set)
    expect(card_set.formats).to contain_exactly(format)
    expect { format.card_sets << card_set }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
