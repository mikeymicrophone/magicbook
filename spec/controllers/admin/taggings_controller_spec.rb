require "rails_helper"

RSpec.describe Admin::TaggingsController, type: :controller do
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-application-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(name: "A list to tag", mage: admin) }
  let!(:context) { TagContext.create!(name: "Archetype", slug: "archetype", kind: "user") }
  let!(:tag) { context.tags.create!(name: "Tempo", slug: "tempo", kind: "user") }

  before { sign_in admin }

  it "lets an admin apply a tag to a list" do
    post :create, params: { tagging: { tag_id: tag.id, list_id: list.id } }

    expect(list.reload.tags).to contain_exactly(tag)
    expect(Tagging.last.mage).to eq(admin)
    expect(response).to redirect_to(admin_tag_contexts_path)
  end
end
