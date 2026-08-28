require "rails_helper"

RSpec.describe Admin::TagsController, type: :controller do
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-tags-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:context) { TagContext.create!(name: "Archetype", slug: "archetype", kind: "user") }

  before { sign_in admin }

  it "lets an admin add a tag to a style" do
    post :create, params: {
      tag_context_id: context.id,
      tag: { name: "Tempo", slug: "tempo" }
    }

    expect(context.tags.find_by!(slug: "tempo")).to have_attributes(name: "Tempo", kind: "user")
    expect(response).to redirect_to(admin_tag_contexts_path)
  end
end
