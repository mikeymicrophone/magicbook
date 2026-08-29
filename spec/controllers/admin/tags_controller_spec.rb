require "rails_helper"

RSpec.describe Admin::TagsController, type: :controller do
  render_views
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-tags-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:owner) do
    Mage.create!(
      email: "tagging-tags-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:context) { TagContext.create!(name: "Archetype", slug: "archetype", kind: "user") }
  let!(:flags) { TagContext.create!(name: "Flags", slug: "flags", kind: "system") }

  before { sign_in admin }

  it "lets an admin add a tag to a style" do
    post :create, params: {
      tag_context_id: context.id,
      tag: { name: "Tempo", slug: "tempo" }
    }

    expect(context.tags.find_by!(slug: "tempo")).to have_attributes(name: "Tempo", kind: "user")
    expect(response).to redirect_to(admin_tag_contexts_path)
  end

  it "creates a tag and applies it to a taggable over Turbo" do
    list = List.create!(name: "A list to tag", mage: admin)

    post :create, params: {
      tag_context_id: context.id,
      taggable_type: "List",
      taggable_id: list.id,
      tag: { name: "Aggro" }
    }, format: :turbo_stream

    tag = context.tags.find_by!(slug: "aggro")
    expect(tag.name).to eq("Aggro")
    expect(list.reload.tags).to contain_exactly(tag)
    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("applied_tags_list_#{list.id}", "Aggro")
    expect(response.body).not_to include("create_tag_list_#{list.id}")
    expect(response.body).not_to include('value="Aggro"')
  end

  it "lets a list owner create a tag and apply it to their list" do
    sign_in owner
    list = List.create!(name: "Owned list to tag", mage: owner)

    post :create, params: {
      tag_context_id: context.id,
      taggable_type: "List",
      taggable_id: list.id,
      tag: { name: "Midrange" }
    }, format: :turbo_stream

    tag = context.tags.find_by!(slug: "midrange")
    expect(tag.kind).to eq("user")
    expect(list.reload.tags).to contain_exactly(tag)
    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("Midrange")
    expect(response.body).not_to include('value="Midrange"')
  end

  it "does not let a list owner create a tag in a system style" do
    sign_in owner
    list = List.create!(name: "Owned list to tag", mage: owner)

    expect do
      post :create, params: {
        tag_context_id: flags.id,
        taggable_type: "List",
        taggable_id: list.id,
        tag: { name: "Suspicious" }
      }
    end.to raise_error(CanCan::AccessDenied)
    expect(flags.tags.find_by(slug: "suspicious")).to be_nil
  end

  it "creates a tag in the selected style rather than the first style" do
    era = TagContext.create!(name: "Era", slug: "era", kind: "user")
    sign_in owner
    list = List.create!(name: "Owned list to tag", mage: owner)

    post :create, params: {
      tag_context_id: context.id,
      taggable_type: "List",
      taggable_id: list.id,
      tag: { name: "Tempo" }
    }, format: :turbo_stream

    tag = Tag.find_by!(slug: "tempo")
    expect(tag.tag_context).to eq(context)
    expect(tag.tag_context).not_to eq(era)
    expect(list.reload.tags).to contain_exactly(tag)
  end

  it "creates an unstyled tag when no style is chosen" do
    sign_in owner
    list = List.create!(name: "Owned list to tag", mage: owner)

    post :create, params: {
      taggable_type: "List",
      taggable_id: list.id,
      tag: { name: "Favorite" }
    }, format: :turbo_stream

    tag = Tag.find_by!(slug: "favorite")
    expect(tag.tag_context).to be_nil
    expect(list.reload.tags).to contain_exactly(tag)
    expect(response.body).to include("Favorite")
    expect(response.body).not_to include("tagging-chip-context")
    expect(response.body).not_to include("create_tag_list_#{list.id}")
  end
end
