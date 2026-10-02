require 'rails_helper'
require 'stringio'
require 'zlib'

RSpec.describe CardCatalog::ScryfallBulkIngest do
  def gzipped_jsonl(records)
    output = StringIO.new
    Zlib::GzipWriter.wrap(output) do |gzip|
      records.each { |record| gzip.puts(record.to_json) }
    end
    StringIO.new(output.string)
  end

  def printing(attributes = {})
    {
      'object' => 'card',
      'id' => SecureRandom.uuid,
      'oracle_id' => '11111111-1111-1111-1111-111111111111',
      'lang' => 'en',
      'games' => ['paper'],
      'digital' => false,
      'name' => 'Fire // Ice',
      'set' => 'APC',
      'set_name' => 'Apocalypse',
      'set_type' => 'expansion',
      'released_at' => '2001-06-04',
      'collector_number' => '128',
      'cmc' => 4,
      'keywords' => ['Fuse'],
      'card_faces' => [
        { 'colors' => ['R'], 'type_line' => 'Instant', 'oracle_text' => 'Fire deals 2 damage divided as you choose among one or two targets.', 'image_uris' => { 'png' => 'https://example.test/fire.png' } },
        { 'colors' => ['U'], 'type_line' => 'Instant', 'oracle_text' => 'Tap target permanent. Draw a card.', 'image_uris' => { 'png' => 'https://example.test/ice.png' } }
      ],
      'promo' => false,
      'variation' => false,
      'full_art' => false,
      'frame_effects' => []
    }.merge(attributes)
  end

  it 'keeps one ordinary printing per set and uses the earliest one as preferred' do
    normal = printing
    showcase = printing('id' => SecureRandom.uuid, 'collector_number' => '128a', 'frame_effects' => ['showcase'])
    reprint = printing(
      'id' => SecureRandom.uuid,
      'set' => 'MH2',
      'set_name' => 'Modern Horizons 2',
      'released_at' => '2021-06-18',
      'collector_number' => '290'
    )

    imported = described_class.new.ingest_io!(gzipped_jsonl([showcase, reprint, normal]))
    concept = CardConcept.find_by!(oracle_id: normal['oracle_id'])

    expect(imported).to eq(2)
    expect(concept.cards.count).to eq(2)
    expect(concept.preferred_printing.card_set.code).to eq('APC')
    expect(concept.preferred_printing).to be_red
    expect(concept.preferred_printing).to be_blue
    expect(concept.preferred_printing.collector_number).to eq('128')
    expect(concept.oracle_text).to include('Fire deals 2 damage', 'Draw a card')
    expect(concept.keywords).to eq(['Fuse'])
  end

  describe 'set release dates' do
    let(:late_addition) do
      printing(
        'id' => SecureRandom.uuid,
        'oracle_id' => '22222222-2222-2222-2222-222222222222',
        'name' => 'Late Addition',
        'collector_number' => '300',
        'released_at' => '2026-04-24'
      )
    end

    it "dates a set from Scryfall's set list, not from the last printing imported" do
      described_class.new.ingest_io!(gzipped_jsonl([printing, late_addition]), set_release_dates: { 'APC' => '2001-06-04' })

      expect(CardSet.find_by!(code: 'APC').released_on).to eq(Date.new(2001, 6, 4))
      expect(Card.find_by!(name: 'Late Addition').released_on).to eq(Date.new(2026, 4, 24))
    end

    it 'falls back to the earliest printing when Scryfall has no date for the set' do
      described_class.new.ingest_io!(gzipped_jsonl([late_addition, printing]))

      expect(CardSet.find_by!(code: 'APC').released_on).to eq(Date.new(2001, 6, 4))
    end
  end

  it 'excludes digital-only records' do
    digital = printing('games' => ['arena'], 'digital' => true)

    expect(described_class.new.ingest_io!(gzipped_jsonl([digital]))).to eq(0)
    expect(Card.count).to eq(0)
  end

  it 'reuses a legacy card when its Multiverse ID belongs to a skipped premium variant' do
    legacy = Card.create!(name: 'Fire // Ice (legacy spelling)', multiverse_id: 42)
    normal = printing
    showcase = printing(
      'id' => SecureRandom.uuid,
      'collector_number' => '128a',
      'frame_effects' => ['showcase'],
      'multiverse_ids' => [42]
    )

    described_class.new.ingest_io!(gzipped_jsonl([normal, showcase]))

    expect(Card.find_by!(multiverse_id: 42)).to have_attributes(
      id: legacy.id,
      card_set: CardSet.find_by!(code: 'APC'),
      collector_number: '128'
    )
  end

  it 'moves a list link without a Multiverse ID to the concept preferred printing' do
    mage = Mage.create!(email: 'catalog@example.test', password: 'password123')
    list = List.create!(mage: mage, name: 'Catalog list')
    item = ListedItem.create!(list: list, designation: 'Fire // Ice')
    legacy = Card.create!(name: 'Fire // Ice')
    inclusion = CardInclusion.create!(card: legacy, piece: item)

    described_class.new.ingest_io!(gzipped_jsonl([printing]))

    expect(inclusion.reload.card).to eq(legacy.card_concept.preferred_printing)
    expect(inclusion.card.card_set.code).to eq('APC')
  end
end
