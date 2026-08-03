require 'rails_helper'

RSpec.describe 'Card sets', type: :request do
  before { host! 'localhost' }
  before { Book.create!(id: 1, title: 'Featured book', version: '1.0.0') }

  def create_printing(set:, name:, collector_number: '1')
    concept = CardConcept.create!(name: name, oracle_id: SecureRandom.uuid)
    Card.create!(
      name: name,
      card_concept: concept,
      card_set: set,
      collector_number: collector_number,
      image_url: 'https://example.test/card.png',
      preferred: true
    )
  end

  it 'browses normal set categories while leaving promo sets filterable' do
    premier = CardSet.create!(code: 'TST', name: 'Test Expansion', released_on: Date.new(2026, 1, 1), category: :premier)
    promo = CardSet.create!(code: 'PST', name: 'Test Promo', released_on: Date.new(2026, 1, 2), category: :promo)
    create_printing(set: premier, name: 'Test Card')
    create_printing(set: promo, name: 'Promo Card')

    get card_sets_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Expansion')
    expect(response.body).not_to include('Test Promo')

    get card_sets_path(category: 'promo')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Promo')
  end

  it 'shows the printings and artwork for one set' do
    card_set = CardSet.create!(code: 'TST', name: 'Test Expansion', category: :premier)
    create_printing(set: card_set, name: 'Test Card', collector_number: '17')

    get card_set_path(card_set)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Card')
    expect(response.body).to include('https://example.test/card.png')
  end
end
