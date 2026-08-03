require 'rails_helper'

RSpec.describe CardCatalog::Importer do
  it 'aggregates split-card colors across faces and chooses a preferred printing' do
    card = described_class.new.import_printing!(
      name: 'Fire // Ice',
      oracle_id: SecureRandom.uuid,
      faces: [
        { colors: ['R'], types: ['Instant'], mana_value: 4 },
        { colors: ['U'], types: ['Instant'], mana_value: 4 }
      ],
      set: { code: 'APC', name: 'Apocalypse', released_on: Date.new(2001, 6, 4), set_type: 'expansion' },
      printing: {
        scryfall_id: SecureRandom.uuid,
        collector_number: '128',
        image_url: 'https://example.test/fire-ice.png',
        preferred: true
      }
    )

    expect(card).to be_red
    expect(card).to be_blue
    expect(card).to be_instant
    expect(card.converted_mana_cost).to eq(4)
    expect(card.card_concept.preferred_printing).to eq(card)
  end
end
