require "rails_helper"

RSpec.describe CardCatalog::StandardEnvironmentSeeder do
  let!(:standard_set) { CardSet.create!(code: "std", name: "Test Standard", category: :premier) }
  let!(:outside_set) { CardSet.create!(code: "old", name: "Rotated set", category: :premier) }

  def concept_with_printing(name, oracle_text:, keywords: [], card_set: standard_set)
    concept = CardConcept.create!(
      name: name,
      oracle_id: SecureRandom.uuid,
      oracle_text: oracle_text,
      keywords: keywords
    )
    Card.create!(name: name, card_concept: concept, card_set: card_set)
    concept
  end

  it "seeds a reusable function graph and classifies only Standard concepts" do
    fight = concept_with_printing("Arena Brawler", oracle_text: "This creature fights target creature you don't control.")
    bite = concept_with_printing("Hunter's Bite", oracle_text: "Target creature you control deals damage equal to its power to target creature.")
    draw = concept_with_printing("Fresh Ideas", oracle_text: "Draw two cards.")
    flier = concept_with_printing("Sky Friend", oracle_text: "Flying", keywords: ["Flying"])
    rotated = concept_with_printing("Old Removal", oracle_text: "Destroy target creature.", card_set: outside_set)

    result = described_class.new(set_codes: [standard_set.code], logger: Logger.new(nil)).call

    standard = result.fetch(:format)
    expect(standard.card_sets).to contain_exactly(standard_set)
    expect(CardFunction.find_by!(slug: "fight").parents.pluck(:slug)).to contain_exactly("damage-removal", "creature-combat")
    expect(CardFunction.find_by!(slug: "removal").card_concepts_including_descendants).to include(fight, bite)
    expect(CardFunction.find_by!(slug: "card-draw").card_concepts).to contain_exactly(draw)
    expect(CardFunction.find_by!(slug: "evasion").card_concepts_including_descendants).to include(flier)
    expect(rotated.card_functions).to be_empty
    expect(CardFunctionAssignment.where(source: described_class::SOURCE).count).to eq(4)

    expect { described_class.new(set_codes: [standard_set.code], logger: Logger.new(nil)).call }
      .not_to change(CardFunctionAssignment, :count)
  end
end
