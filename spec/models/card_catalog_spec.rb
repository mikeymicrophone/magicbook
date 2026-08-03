require 'rails_helper'

RSpec.describe 'card catalog', type: :model do
  it 'keeps existing cards connected to a canonical concept' do
    card = Card.create!(name: 'Lightning Bolt')

    expect(card.card_concept.name).to eq('Lightning Bolt')
  end

  it 'allows a concept to have many printings while preserving a preferred one' do
    concept = CardConcept.create!(name: 'Lightning Bolt', oracle_id: SecureRandom.uuid)
    alpha = CardSet.create!(code: 'LEA', name: 'Limited Edition Alpha', released_on: Date.new(1993, 8, 5))
    masters = CardSet.create!(code: 'M25', name: 'Masters 25', released_on: Date.new(2018, 3, 16))

    original = Card.create!(name: concept.name, card_concept: concept, card_set: alpha, preferred: true)
    reprint = Card.create!(name: concept.name, card_concept: concept, card_set: masters)

    expect(concept.preferred_printing).to eq(original)
    expect(reprint.card_concept).to eq(concept)
  end

  it 'supports functions with multiple parents and rejects cycles' do
    removal = CardFunction.create!(name: 'Removal', slug: 'removal')
    combat = CardFunction.create!(name: 'Creature combat', slug: 'creature-combat')
    damage_removal = CardFunction.create!(name: 'Damage-based creature removal', slug: 'damage-removal')
    fight = CardFunction.create!(name: 'Fight', slug: 'fight')

    CardFunctionRelation.create!(parent_function: removal, child_function: damage_removal)
    CardFunctionRelation.create!(parent_function: combat, child_function: damage_removal)
    CardFunctionRelation.create!(parent_function: damage_removal, child_function: fight)

    expect(fight.ancestor_ids).to contain_exactly(removal.id, combat.id, damage_removal.id)
    expect(CardFunctionRelation.new(parent_function: fight, child_function: removal)).not_to be_valid
  end
end
