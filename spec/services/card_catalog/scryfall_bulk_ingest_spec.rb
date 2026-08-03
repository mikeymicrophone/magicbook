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
      'card_faces' => [
        { 'colors' => ['R'], 'type_line' => 'Instant', 'image_uris' => { 'png' => 'https://example.test/fire.png' } },
        { 'colors' => ['U'], 'type_line' => 'Instant', 'image_uris' => { 'png' => 'https://example.test/ice.png' } }
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
    magician = Magician.create!(email: 'catalog@example.test', password: 'password123')
    list = List.create!(magician: magician, name: 'Catalog list')
    item = ListedItem.create!(list: list, designation: 'Fire // Ice')
    legacy = Card.create!(name: 'Fire // Ice')
    inclusion = CardInclusion.create!(card: legacy, piece: item)

    described_class.new.ingest_io!(gzipped_jsonl([printing]))

    expect(inclusion.reload.card).to eq(legacy.card_concept.preferred_printing)
    expect(inclusion.card.card_set.code).to eq('APC')
  end
end
