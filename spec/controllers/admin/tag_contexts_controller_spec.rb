require "rails_helper"

RSpec.describe Admin::TagContextsController, type: :controller do
  let!(:admin) do
    Mage.create!(
      admin: true,
      email: "tagging-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end

  before { sign_in admin }

  it "lets an admin create a user-managed tag style" do
    post :create, params: { tag_context: { name: "Archetype", slug: "archetype" } }
    context = TagContext.find_by!(slug: "archetype")

    expect(context.kind).to eq("user")
    expect(context.color).to eq(HexColor::DEFAULT)
    expect(response).to redirect_to(admin_tag_contexts_path)
  end

  it "lets an admin set a style color" do
    post :create, params: { tag_context: { name: "Palette", slug: "palette", color: "#4a628a" } }

    expect(TagContext.find_by!(slug: "palette").color).to eq("#4a628a")
  end
end
