require "rails_helper"

RSpec.describe "UUIDv7 primary keys" do
  let(:uuid_v7_pattern) { /\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i }
  let(:mage) do
    Mage.create!(
      email: "uuid-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end

  it "configures ActiveRecord generators to default to UUID primary keys" do
    expect(Rails.application.config.generators.options.dig(:active_record, :primary_key_type)).to eq(:uuid)
  end

  it "assigns time-ordered RFC 9562 UUIDv7 IDs on ApplicationRecord models" do
    ids = 5.times.map { |n| Chapter.create!(title: "Chapter #{n}").id }

    expect(ids).to all(match(uuid_v7_pattern))
    expect(ids).to eq(ids.sort)
    expect(ids.uniq.size).to eq(5)
  end

  it "preserves a client-supplied UUIDv7" do
    preset_id = SecureRandom.uuid_v7

    expect(Paragraph.create!(id: preset_id, text: "Preset").id).to eq(preset_id)
    expect(Book.create!(id: preset_id, title: "Preset", version: "1.0.0").id).to eq(preset_id)
  end

  it "assigns UUIDv7 IDs on ActiveStorage records for books and editions" do
    book = Book.create!(title: "Stored book", version: "1.0.0")
    edition = Edition.create!(major: 1, minor: 0, patch: 0)
    book.pdf.attach(io: StringIO.new("pdf"), filename: "book.pdf", content_type: "application/pdf")
    edition.pdf.attach(io: StringIO.new("pdf"), filename: "edition.pdf", content_type: "application/pdf")

    [book, edition].each do |record|
      expect(record.pdf.blob.id).to match(uuid_v7_pattern)
      expect(record.pdf.attachment.id).to match(uuid_v7_pattern)
      expect(record.pdf.attachment.record_id).to eq(record.id)
    end
  end

  describe "slugged to_param lookups" do
    let(:book) { Book.create!(title: "Ways We Enjoy Magic Cards", version: "1.0.0") }
    let(:list) { List.create!(mage: mage, name: "Best Red Cards!", privacy: :published) }
    let(:tag_context) { TagContext.create!(name: "Format", slug: "format", kind: "user") }
    let(:tag) { tag_context.tags.create!(name: "Commander", slug: "commander", kind: "user") }

    it "finds a book and a list by their slugged param" do
      expect(book.to_param).to eq("#{book.id}-Ways-We-Enjoy-Magic-Cards")
      expect(Book.find(book.to_param)).to eq(book)
      expect(Book.find(book.id)).to eq(book)
      expect(Book.where(id: book.to_param)).to contain_exactly(book)

      expect(list.to_param).to eq("#{list.id}-Best-Red-Cards-")
      expect(List.find(list.to_param)).to eq(list)
      expect(List.find(list.id)).to eq(list)
    end

    it "finds a tag by its id with or without the style and tag slugs" do
      expect(Tag.includes(:tag_context).find("#{tag.id}-format-commander")).to eq(tag)
      expect(tag_context.tags.find("#{tag.id}-format-commander")).to eq(tag)
      expect(Tag.includes(:tag_context).find(tag.to_param)).to eq(tag)
      expect(tag_context.tags.find(tag.to_param)).to eq(tag)
      expect(Tag.find(tag.id)).to eq(tag)
    end

    it "keeps assigning UUIDv7 IDs on the models that cast slugged ids" do
      expect(Book.columns_hash["id"].type).to eq(:uuid)
      expect([book.id, list.id, tag.id]).to all(match(uuid_v7_pattern))
    end

    it "raises RecordNotFound for ids that are not UUIDs" do
      ["123", "not-a-uuid", "", "#{book.id.delete('-')}-x"].each do |bad|
        expect { Book.find(bad) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { List.find(bad) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Tag.includes(:tag_context).find(bad) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { tag_context.tags.find(bad) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      expect { Chapter.find("123") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "round-trips listed_items.replacing as a UUID" do
    list = List.create!(mage: mage, name: "Replacements", privacy: :published)
    original = list.listed_items.create!(designation: "Original", privacy: :published)
    revision = list.listed_items.create!(designation: "Revision", privacy: :suggested, replacing: original.id)

    expect(revision.reload.replacing).to eq(original.id)
    expect(ListedItem.find_by(id: revision.replacing)).to eq(original)
    expect(ListedItem.columns_hash["replacing"].type).to eq(:uuid)
  end

  it "stores polymorphic references as UUIDs" do
    list = List.create!(mage: mage, name: "Polymorphic", privacy: :published)
    nested = List.create!(mage: mage, name: "Nested", privacy: :published)
    item = list.listed_items.create!(designation: "Nested list", content: nested)
    tag = Tag.create!(name: "Sleeper")
    tagging = item.taggings.create!(tag: tag, mage: mage)

    expect(item.reload.content).to eq(nested)
    expect(tagging.reload.taggable).to eq(item)
    expect(Tagging.columns_hash["taggable_id"].type).to eq(:uuid)
    expect(ListedItem.columns_hash["content_id"].type).to eq(:uuid)
    expect(CardInclusion.columns_hash["piece_id"].type).to eq(:uuid)
  end

  it "keeps non-reference integer columns as integers" do
    expect(Book.columns_hash["price_cents"].type).to eq(:integer)
    expect(Card.columns_hash["multiverse_id"].type).to eq(:integer)
    expect(Passkey.columns_hash["sign_count"].type).to eq(:integer)
    expect(ListedItem.columns_hash["ordering"].type).to eq(:integer)
    expect(ActiveStorage::Blob.columns_hash["byte_size"].type).to eq(:integer)
  end

  it "uses uuid primary keys on all application tables while keeping solid_queue tables integer" do
    conn = ApplicationRecord.connection
    app_tables = conn.tables.reject { |table| %w[schema_migrations ar_internal_metadata].include?(table) || table.start_with?("solid_") }

    expect(app_tables.size).to eq(34)
    non_uuid_tables = app_tables.select { |table| conn.columns(table).find { |column| column.name == "id" }&.type != :uuid }
    expect(non_uuid_tables).to be_empty

    solid_queue_tables = conn.tables.select { |table| table.start_with?("solid_queue_") }
    expect(solid_queue_tables.size).to eq(11)
    solid_queue_tables.each do |table|
      expect(conn.columns(table).find { |column| column.name == "id" }.type).to eq(:integer), "expected #{table}.id to remain integer"
    end
  end
end

RSpec.describe ListsController, type: :controller do
  render_views

  let(:mage) do
    Mage.create!(email: "uuid-cancan@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
  end
  let!(:list) { List.create!(mage: mage, name: "Slugged list", privacy: :published) }

  before do
    create_featured_book!
    sign_in mage
  end

  it "lets CanCanCan load a list from its slugged param" do
    get :show, params: { id: list.to_param }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Slugged list")
  end

  it "raises RecordNotFound for a non-UUID list id" do
    expect { get :show, params: { id: "123" } }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

RSpec.describe BooksController, type: :controller do
  render_views

  let(:mage) do
    Mage.create!(admin: true, email: "uuid-book-admin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
  end

  before { sign_in mage }

  it "lets CanCanCan load a book from its slugged param" do
    book = create_featured_book!

    get :show, params: { id: book.to_param }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Featured book")
  end
end
