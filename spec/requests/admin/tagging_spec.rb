require "rails_helper"

RSpec.describe "Admin tagging", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-page-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:flags) { TagContext.create!(name: "Flags", slug: "flags", kind: "system") }
  let!(:ai_generated) { flags.tags.create!(name: "AI generated", slug: "ai-generated", kind: "system") }
  let!(:list) { List.create!(name: "Admin tagging list", mage: admin) }

  before do
    host! "localhost"
    Book.create!(id: 1, title: "Featured book", version: "1.0.0")
    sign_in admin
  end

  it "shows the protected system tag and list application control" do
    get admin_tag_contexts_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Tagging", "Flags", "AI generated", "Admin tagging list", "Apply to list")
    expect(response.body).not_to include("Delete style")
  end

  it "shows tagging helpers on a list for an admin" do
    get list_path(list)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Apply an existing tag", "Add tag", "AI generated")
  end

  it "shows tagging helpers on a list for the owner" do
    owner = Mage.create!(
      email: "tagging-page-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
    owned_list = List.create!(name: "Owner tagging list", mage: owner)
    TagContext.create!(name: "Format", slug: "format", kind: "user").tags.create!(name: "Commander", slug: "commander", kind: "user")
    sign_in owner

    get list_path(owned_list)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Apply an existing tag", "Add tag", "Commander")
    expect(response.body).not_to include("AI generated")
  end

  it "creates a panel tag in the style chosen in the form" do
    era = TagContext.create!(name: "Era", slug: "era", kind: "user")
    format = TagContext.create!(name: "Format", slug: "format", kind: "user")
    owner = Mage.create!(
      email: "tagging-style-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
    owned_list = List.create!(name: "Style choice list", mage: owner)
    sign_in owner

    post admin_tags_path, params: {
      tag_context_id: format.id,
      taggable_type: "List",
      taggable_id: owned_list.id,
      tag: { name: "Commander" }
    }, as: :turbo_stream

    tag = Tag.find_by!(name: "Commander")
    expect(tag.tag_context).to eq(format)
    expect(tag.tag_context).not_to eq(era)
    expect(owned_list.reload.tags).to contain_exactly(tag)
  end

  it "creates an unstyled tag from the panel by default" do
    owner = Mage.create!(
      email: "tagging-unstyled-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
    owned_list = List.create!(name: "Unstyled tag list", mage: owner)
    sign_in owner

    post admin_tags_path, params: {
      taggable_type: "List",
      taggable_id: owned_list.id,
      tag: { name: "Favorite" }
    }, as: :turbo_stream

    tag = Tag.find_by!(name: "Favorite")
    expect(tag.tag_context).to be_nil
    expect(owned_list.reload.tags).to contain_exactly(tag)
    expect(response.body).to include("Favorite")
    expect(response.body).not_to include("tagging-chip-context")
  end
end
