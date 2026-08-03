require 'rails_helper'

RSpec.describe 'Card functions', type: :request do
  before do
    host! 'localhost'
    Book.create!(id: 1, title: 'Featured book', version: '1.0.0')
  end

  it 'browses the graph with direct and descendant-inclusive counts' do
    removal = CardFunction.create!(name: 'Removal', slug: 'removal')
    combat = CardFunction.create!(name: 'Creature combat', slug: 'creature-combat')
    fight = CardFunction.create!(name: 'Fight', slug: 'fight')
    CardFunctionRelation.create!(parent_function: removal, child_function: fight)
    CardFunctionRelation.create!(parent_function: combat, child_function: fight)

    concept = CardConcept.create!(name: 'Arena Brawler', oracle_id: SecureRandom.uuid)
    CardFunctionAssignment.create!(card_function: fight, card_concept: concept, source: 'spec')

    get card_functions_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('What cards do', 'Removal', 'Creature combat', 'Fight')
    expect(Nokogiri::HTML(response.body).text).to include('1 card in this branch')
    expect(response.body).to include(card_function_path(fight.slug))
  end

  it 'shows preferred printings classified anywhere below the selected function' do
    removal = CardFunction.create!(name: 'Removal', slug: 'removal')
    fight = CardFunction.create!(name: 'Fight', slug: 'fight')
    CardFunctionRelation.create!(parent_function: removal, child_function: fight)

    set = CardSet.create!(code: 'TST', name: 'Test Expansion', category: :premier)
    included = CardConcept.create!(name: 'Arena Brawler', oracle_id: SecureRandom.uuid)
    excluded = CardConcept.create!(name: 'Helpful Sprite', oracle_id: SecureRandom.uuid)
    printing = Card.create!(name: included.name, card_concept: included, card_set: set, preferred: true, image_url: 'https://example.test/arena.png')
    Card.create!(name: excluded.name, card_concept: excluded, card_set: set, preferred: true)
    CardFunctionAssignment.create!(card_function: fight, card_concept: included, source: 'spec')

    get card_function_path(removal.slug)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Arena Brawler', 'https://example.test/arena.png', card_path(printing))
    expect(response.body).not_to include('Helpful Sprite')
  end
end
