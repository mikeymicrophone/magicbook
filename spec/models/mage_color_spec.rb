require "rails_helper"

RSpec.describe Mage, type: :model do
  let!(:mage) { Fabricate(:mage) }
  let!(:format) { TagContext.create!(name: "Format", slug: "format-colors", kind: "user", color: "#3d6b5a") }

  it "uses the style color until the mage overrides it" do
    expect(mage.color_for_tag_context(format)).to eq("#3d6b5a")

    mage.sync_tag_context_color_overrides!(format.id.to_s => "#8a4a32")

    expect(mage.color_for_tag_context(format.reload)).to eq("#8a4a32")
    expect(mage.tag_context_color_overrides.sole.tag_context).to eq(format)
  end

  it "drops an override that matches the site color" do
    mage.tag_context_color_overrides.create!(tag_context: format, color: "#8a4a32")

    mage.sync_tag_context_color_overrides!(format.id.to_s => format.color)

    expect(mage.tag_context_color_overrides).to be_empty
    expect(mage.color_for_tag_context(format)).to eq("#3d6b5a")
  end
end
