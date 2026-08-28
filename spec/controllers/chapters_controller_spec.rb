require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  render_views

  let!(:scribe) do
    Mage.create!(admin: true,
      email: 'chapter-turbo-scribe@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:book) { Fabricate(:book) }
  let!(:edition) { Edition.create!(major: 1, minor: 0, patch: 0, release: 1.day.ago) }
  let!(:edition_table_of_content) { TableOfContent.create!(book: book, edition: edition) }
  let!(:first_chapter) { Chapter.create!(title: 'First chapter') }
  let!(:first_chapter_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: first_chapter) }
  let!(:second_chapter) { Chapter.create!(title: 'Second chapter') }
  let!(:second_chapter_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: second_chapter) }

  before { sign_in scribe }

  it 'creates a chapter with a Turbo Stream response that refreshes the chapter list' do
    expect do
      post :create,
           params: { table_of_content_id: edition_table_of_content.id, chapter: { title: 'Turbo chapter', subtitle: 'A stream response' } },
           format: :turbo_stream
    end.to change(Chapter, :count).by(1)

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(edition, :chapters)}\"")
  end

  it 'reorders chapters with a Turbo Stream response that refreshes the chapter list' do
    put :promote,
        params: { id: second_chapter.id, table_of_content_id: second_chapter_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(edition, :chapters)}\"")
    expect(second_chapter_table_of_content.reload.ordering).to be < first_chapter_table_of_content.reload.ordering
  end

  it 'updates and removes chapters with Turbo Stream responses' do
    patch :update,
          params: { id: first_chapter.id, table_of_content_id: first_chapter_table_of_content.id, chapter: { title: 'Renamed chapter', subtitle: 'Updated' } },
          format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(edition, :chapters)}\"")

    delete :destroy,
           params: { id: second_chapter.id, table_of_content_id: second_chapter_table_of_content.id },
           format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(edition, :chapters)}\"")
  end

  it 'selects a free chapter by its ordered position, including index zero' do
    allow(Date).to receive(:today).and_return(Date.new(2026, 8, 28))
    allow(Book).to receive(:featured).and_return(book)

    get :free, params: { book_id: book.id }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('First chapter')
    expect(response.body).to include(next_book_chapter_path(book, second_chapter, edition_id: edition.id))
  end
end
