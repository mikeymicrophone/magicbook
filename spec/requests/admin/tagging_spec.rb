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
end
