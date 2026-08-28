require "rails_helper"

RSpec.describe Tagging::SystemSeeder do
  it "seeds flags/ai-generated and editable Magic starter contexts idempotently" do
    tag = described_class.new.call

    expect(tag).to have_attributes(slug: "ai-generated", name: "AI generated", kind: "system")
    expect(tag.tag_context).to have_attributes(slug: "flags", name: "Flags", kind: "system")
    expect(TagContext.where(kind: "user").order(:slug).pluck(:slug, :name)).to eq([
      ["era", "Era"],
      ["format", "Format"],
      ["power-level", "Power level"],
      ["strategy", "Strategy"]
    ])

    expect { described_class.new.call }.not_to change { [Tag.count, TagContext.count] }
  end

  it "makes each starter context available through Fabrication" do
    expect(Fabricate(:format_tag_context)).to have_attributes(name: "Format", slug: "format", kind: "user")
    expect(Fabricate(:strategy_tag_context)).to have_attributes(name: "Strategy", slug: "strategy", kind: "user")
    expect(Fabricate(:power_level_tag_context)).to have_attributes(name: "Power level", slug: "power-level", kind: "user")
    expect(Fabricate(:era_tag_context)).to have_attributes(name: "Era", slug: "era", kind: "user")
  end
end
