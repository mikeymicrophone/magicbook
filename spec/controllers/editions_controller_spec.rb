require 'rails_helper'

RSpec.describe EditionsController, type: :controller do
  let(:admin) do
    Mage.create!(
      admin: true,
      email: 'edition-release-admin@example.test',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let(:book) { Book.create!(title: 'Release controller test', author: 'Test', version: '0.1.0', price_cents: 0) }
  let(:edition) { Edition.create!(major: 0, minor: 1, patch: 0) }

  before do
    sign_in admin
    TableOfContent.create!(book: book, edition: edition)
  end

  it 'redirects with an alert instead of creating another successor when the edition is already released' do
    edition.release_for!(book)

    put :release, params: { id: edition.id, book_id: book.id }

    expect(response).to redirect_to(edit_book_path(book))
    expect(flash[:alert]).to include('already been released')
    expect(book.editions.where(major: 0, minor: 2, patch: 0).count).to eq(1)
  end

end
