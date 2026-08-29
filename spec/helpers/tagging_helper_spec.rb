require "rails_helper"

RSpec.describe TaggingHelper, type: :helper do
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-helper-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:reader) do
    Mage.create!(
      email: "tagging-helper-reader@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:context) { TagContext.create!(name: "Format", slug: "format", kind: "user") }
  let!(:tag) { context.tags.create!(name: "Commander", slug: "commander", kind: "user") }
  let!(:flags) { TagContext.create!(name: "Flags", slug: "flags", kind: "system") }
  let!(:system_tag) { flags.tags.create!(name: "AI generated", slug: "ai-generated", kind: "system") }
  let!(:list) { List.create!(name: "Helper tagged list", mage: admin) }
  let!(:owned_list) { List.create!(name: "Reader's list", mage: reader) }

  it "renders a distinct control for applying an existing tag" do
    allow(helper).to receive(:current_mage).and_return(admin)

    html = helper.apply_existing_tag_to(list).to_s

    expect(html).to include("Apply an existing tag", "Format: Commander", "Flags: AI generated")
    expect(html).to include("data-controller=\"apply-existing-tag\"")
    expect(html).to include("data-turbo=\"true\"")
    expect(html).to include("data-turbo-frame=\"_top\"")
    expect(html).to include("data-turbo-stream=\"true\"")
  end

  it "renders a distinct control for creating a new tag" do
    allow(helper).to receive(:current_mage).and_return(admin)

    html = helper.create_tag_for(list).to_s

    expect(html).to include("Add tag", "Choose a style", "No style")
    expect(html).to include("aria-expanded=\"false\"")
    expect(html).to include("aria-haspopup=\"listbox\"")
    expect(html).to include("role=\"option\"")
    expect(html).to include("data-style-color=")
    expect(html).not_to include("<details")
    expect(html).to include("data-controller=\"create-tag\"")
    expect(html).to include("data-turbo=\"true\"")
    expect(html).to include("data-turbo-frame=\"_top\"")
    expect(html).to include("data-turbo-stream=\"true\"")
    expect(html).to include("name=\"tag_context_id\"")
    expect(html).to include(admin_tags_path)
    expect(html).not_to include("data-remote=\"true\"")
    expect(html).not_to include(">Name</span>")
    expect(html).not_to include("Create a new tag")
  end

  it "lets a list owner apply and create tags on their list" do
    allow(helper).to receive(:current_mage).and_return(reader)

    apply_html = helper.apply_existing_tag_to(owned_list).to_s
    create_html = helper.create_tag_for(owned_list).to_s

    expect(apply_html).to include("Apply an existing tag", "Format: Commander")
    expect(apply_html).not_to include("AI generated")
    expect(create_html).to include("Add tag", "Choose a style", "No style")
    expect(create_html).to include("Format")
    expect(create_html).not_to include("Flags")
  end

  it "lets a list owner tag items on their list" do
    listed_item = owned_list.listed_items.create!(designation: "A card")
    allow(helper).to receive(:current_mage).and_return(reader)

    expect(helper.apply_existing_tag_to(listed_item).to_s).to include("Apply an existing tag")
    expect(helper.create_tag_for(listed_item).to_s).to include("Add tag")
  end

  it "hides both controls from anyone who does not own the list" do
    allow(helper).to receive(:current_mage).and_return(reader)

    expect(helper.apply_existing_tag_to(list)).to be_nil
    expect(helper.create_tag_for(list)).to be_nil
  end

  it "keeps tagging forms on the page with Turbo" do
    allow(helper).to receive(:current_mage).and_return(admin)

    html = helper.tagging_for(list).to_s

    expect(html).to include("data-controller=\"tagging-panel\"")
    expect(html).to include("data-turbo=\"true\"")
    expect(html).to include("data-controller=\"tagging-disclosure\"")
    expect(html).to include("tagging-disclosure-panel hidden")
    expect(html).to include("Add tag")
  end

  it "shows applied chips outside the picker disclosure" do
    list.taggings.create!(tag: tag, mage: admin)
    allow(helper).to receive(:current_mage).and_return(admin)

    html = helper.tagging_for(list).to_s
    hidden_at = html.index("tagging-disclosure-panel hidden")

    expect(html).to include("Commander", "tagging-chip", "Add tag")
    expect(html.index("tagging-applied")).to be < hidden_at
    expect(html.index("Commander")).to be < hidden_at
    expect(html[hidden_at..]).to include("Add tag")
    expect(html[hidden_at..]).not_to include("Commander")
  end

  it "puts the tagging picker behind a disclosure button" do
    listed_item = owned_list.listed_items.create!(designation: "A card")
    allow(helper).to receive(:current_mage).and_return(reader)

    html = helper.tagging_disclosure_for(listed_item).to_s

    expect(html).to include("data-controller=\"tagging-disclosure\"")
    expect(html).to include("aria-label=\"Tags\"")
    expect(html).to include("tagging-disclosure-panel hidden")
    expect(html).to match(%r{/assets/tag[-.]})
    expect(html).to include("Add tag")
    expect(html).not_to include("tagging-applied")
  end

  it "colors styled chips from the style, with a viewer override" do
    context.update!(color: "#3d6b5a")
    list.taggings.create!(tag: tag, mage: admin)
    allow(helper).to receive(:current_mage).and_return(reader)

    html = helper.applied_tags_for(list).to_s
    expect(html).to include("tagging-chip")
    expect(html).to include("is-styled")
    expect(html).to include("--tag-color: #3d6b5a")

    reader.tag_context_color_overrides.create!(tag_context: context, color: "#8a4a32")
    html = helper.applied_tags_for(list).to_s
    expect(html).to include("--tag-color: #8a4a32")
    expect(html).not_to include("--tag-color: #3d6b5a")
  end
end
