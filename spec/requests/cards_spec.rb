require 'rails_helper'

RSpec.describe 'Cards', type: :request do
  before do
    host! 'localhost'
    Book.create!(id: 1, title: 'Featured book', version: '1.0.0')
  end

  it 'links a printing to its set and published list memberships' do
    card_set = CardSet.create!(code: 'TST', name: 'Test Expansion', category: :premier)
    concept = CardConcept.create!(name: 'Test Card', oracle_id: SecureRandom.uuid)
    card = Card.create!(name: 'Test Card', card_concept: concept, card_set: card_set, collector_number: '17', image_url: 'https://example.test/card.png')
    magician = Magician.create!(email: 'cards@example.test', password: 'password123')
    published_list = List.create!(magician: magician, name: 'Published card list', privacy: :published)
    private_list = List.create!(magician: magician, name: 'Private card list', privacy: :secret)
    published_item = ListedItem.create!(list: published_list, designation: 'Test Card', privacy: :published)
    private_item = ListedItem.create!(list: private_list, designation: 'Test Card', privacy: :secret)
    CardInclusion.create!(card: card, piece: published_item)
    CardInclusion.create!(card: card, piece: private_item)
    card_function = CardFunction.create!(name: 'Card draw', slug: 'card-draw')
    CardFunctionAssignment.create!(card_concept: concept, card_function: card_function, source: 'spec')

    get card_path(card)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Expansion')
    expect(response.body).to include('Published card list')
    expect(response.body).not_to include('Private card list')
    expect(response.body).to include('Card draw', card_function_path(card_function))

    get card_set_path(card_set)

    expect(response.body).to include(card_path(card))
  end
end
