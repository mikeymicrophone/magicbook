require 'rails_helper'

RSpec.describe 'card printing legality', type: :model do
  let!(:standard) { Format.create!(code: 'standard', name: 'Standard') }
  let!(:pioneer) { Format.create!(code: 'pioneer', name: 'Pioneer') }
  let!(:old_set) { CardSet.create!(code: 'OLD', name: 'Old set', released_on: Date.new(2018, 1, 1), category: :premier) }
  let!(:new_set) { CardSet.create!(code: 'NEW', name: 'New set', released_on: Date.new(2025, 1, 1), category: :premier) }
  let!(:concept) { CardConcept.create!(name: 'Reprinted card', oracle_id: SecureRandom.uuid) }
  let!(:original) { Card.create!(name: concept.name, card_concept: concept, card_set: old_set, released_on: old_set.released_on) }
  let!(:reprint) { Card.create!(name: concept.name, card_concept: concept, card_set: new_set, released_on: new_set.released_on) }

  before do
    standard.card_sets << new_set
    pioneer.card_sets << old_set
  end

  it 'recognizes newer printings without storing a stale boolean' do
    expect(original.newer_printings).to contain_exactly(reprint)
    expect(original).to have_newer_printing
    expect(reprint).not_to have_newer_printing
  end

  it 'treats every printing as legal when its canonical card has a printing in that format' do
    expect(original).to be_legal_in(standard)
    expect(reprint).to be_legal_in(standard)
    expect(Card.legal_in(standard)).to contain_exactly(original, reprint)
    expect(standard.card_concepts).to contain_exactly(concept)
  end

  it 'resolves the newest printing available in a chosen format' do
    expect(original.latest_printing_for(standard)).to eq(reprint)
    expect(reprint.latest_printing_for(pioneer)).to eq(original)
  end

  it 'scopes list positions by the canonical card rather than only their historical printing' do
    mage = Mage.create!(email: 'legality@example.test', password: 'password123')
    list = List.create!(mage: mage, name: 'Reprints in a list', privacy: :published)
    item = ListedItem.create!(list: list, designation: concept.name, privacy: :published)
    CardInclusion.create!(card: original, piece: item)

    expect(ListedItem.with_cards_legal_in(standard)).to contain_exactly(item)
    expect(List.with_cards_legal_in(standard)).to contain_exactly(list)
  end
end
