require "rails_helper"

RSpec.describe TagContext, type: :model do
  it "assigns a default color and normalizes hex" do
    context = described_class.create!(name: "Archetype", slug: "archetype", kind: "user")

    expect(context.color).to eq(HexColor::DEFAULT)
  end

  it "normalizes a supplied color" do
    context = described_class.create!(name: "Archetype", slug: "archetype", kind: "user", color: "#F0C")

    expect(context.color).to eq("#ff00cc")
  end

  it "rejects an invalid color" do
    context = described_class.new(name: "Archetype", slug: "archetype", kind: "user", color: "blue")

    expect(context).not_to be_valid
    expect(context.errors[:color]).to be_present
  end
end
