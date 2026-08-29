require "rails_helper"

RSpec.describe Admin::TaggingsController, type: :controller do
  render_views
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-application-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:owner) do
    Mage.create!(
      email: "tagging-application-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(name: "A list to tag", mage: admin) }
  let!(:owned_list) { List.create!(name: "An owned list to tag", mage: owner) }
  let!(:context) { TagContext.create!(name: "Archetype", slug: "archetype", kind: "user") }
  let!(:tag) { context.tags.create!(name: "Tempo", slug: "tempo", kind: "user") }
  let!(:flags) { TagContext.create!(name: "Flags", slug: "flags", kind: "system") }
  let!(:system_tag) { flags.tags.create!(name: "AI generated", slug: "ai-generated", kind: "system") }

  before { sign_in admin }

  it "lets an admin apply a tag to a list" do
    post :create, params: { tagging: { tag_id: tag.id, list_id: list.id } }

    expect(list.reload.tags).to contain_exactly(tag)
    expect(Tagging.last.mage).to eq(admin)
    expect(response).to redirect_to(admin_tag_contexts_path)
  end

  it "applies a tag to a taggable and replaces the Turbo tagging panel" do
    post :create, params: {
      tagging: { tag_id: tag.id, taggable_type: "List", taggable_id: list.id }
    }, format: :turbo_stream

    expect(list.reload.tags).to contain_exactly(tag)
    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("applied_tags_list_#{list.id}", "Tempo")
  end

  it "lets a list owner apply a tag to their list" do
    sign_in owner

    post :create, params: {
      tagging: { tag_id: tag.id, taggable_type: "List", taggable_id: owned_list.id }
    }, format: :turbo_stream

    expect(owned_list.reload.tags).to contain_exactly(tag)
    expect(Tagging.last.mage).to eq(owner)
    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
  end

  it "lets a list owner apply a tag to an item on their list" do
    sign_in owner
    listed_item = owned_list.listed_items.create!(designation: "A card")

    post :create, params: {
      tagging: { tag_id: tag.id, taggable_type: "ListedItem", taggable_id: listed_item.id }
    }, format: :turbo_stream

    expect(listed_item.reload.tags).to contain_exactly(tag)
    expect(response.body).to include("applied_tags_listed_item_#{listed_item.id}")
  end

  it "does not let a mage tag someone else's list" do
    sign_in owner

    expect do
      post :create, params: {
        tagging: { tag_id: tag.id, taggable_type: "List", taggable_id: list.id }
      }
    end.to raise_error(CanCan::AccessDenied)
    expect(list.reload.tags).to be_empty
  end

  it "does not let a list owner apply a system tag" do
    sign_in owner

    expect do
      post :create, params: {
        tagging: { tag_id: system_tag.id, taggable_type: "List", taggable_id: owned_list.id }
      }
    end.to raise_error(CanCan::AccessDenied)
    expect(owned_list.reload.tags).to be_empty
  end
end
