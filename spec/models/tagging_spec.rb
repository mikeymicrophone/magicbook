require "rails_helper"

RSpec.describe Tagging, type: :model do
  let!(:flags) { TagContext.create!(slug: "flags", name: "Flags", kind: "system") }
  let!(:ai_generated) { flags.tags.create!(slug: "ai-generated", name: "AI generated", kind: "system") }
  let!(:mage) { Fabricate(:mage) }

  it "attaches a tag to a list and records who applied it" do
    list = List.create!(name: "Generated cards", mage: mage)

    tagging = described_class.create!(tag: ai_generated, taggable: list, mage: mage)

    expect(list.reload.tags).to contain_exactly(ai_generated)
    expect(tagging.mage).to eq(mage)
  end

  it "supports the same tag on a book and a chapter" do
    book = Fabricate(:book)
    chapter = Fabricate(:chapter)

    book.tags << ai_generated
    chapter.tags << ai_generated

    expect(book.tags).to contain_exactly(ai_generated)
    expect(chapter.tags).to contain_exactly(ai_generated)
  end

  it "allows a tag only once per taggable" do
    list = List.create!(name: "Generated cards", mage: mage)
    described_class.create!(tag: ai_generated, taggable: list)

    duplicate = described_class.new(tag: ai_generated, taggable: list)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:tag_id]).to include("has already been taken")
  end

  it "keeps system contexts and tags from being removed or renamed" do
    expect(flags.destroy).to be_falsey
    expect(flags.errors[:base]).to include("System tag contexts cannot be destroyed")

    expect(ai_generated.update(name: "Machine generated")).to be_falsey
    expect(ai_generated.errors[:base]).to include("System tags cannot be renamed")

    expect(ai_generated.destroy).to be_falsey
    expect(ai_generated.errors[:base]).to include("System tags cannot be destroyed")
  end
end
