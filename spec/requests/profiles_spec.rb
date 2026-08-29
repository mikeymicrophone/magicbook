require "rails_helper"

RSpec.describe "Profiles", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:mage) do
    Mage.create!(
      email: "profile-owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end
  let!(:format) { TagContext.create!(name: "Format", slug: "profile-format", kind: "user", color: "#3d6b5a") }

  before do
    host! "localhost"
    Book.create!(id: 1, title: "Featured book", version: "1.0.0")
  end

  it "requires a signed-in mage" do
    get profile_path

    expect(response).to redirect_to(new_mage_session_path)
  end

  it "lets a mage override and reset a tag style color" do
    sign_in mage

    get profile_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Profile", "Format", "#3d6b5a", "Use site color")

    patch profile_path, params: { style_colors: { format.id.to_s => "#8a4a32" } }
    expect(response).to redirect_to(profile_path)
    expect(mage.reload.color_for_tag_context(format)).to eq("#8a4a32")

    patch profile_path, params: { style_colors: { format.id.to_s => "#3d6b5a" } }
    expect(mage.reload.tag_context_color_overrides).to be_empty
  end
end
