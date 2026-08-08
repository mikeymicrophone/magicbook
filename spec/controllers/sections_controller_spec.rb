require 'rails_helper'

RSpec.describe SectionsController, type: :controller do
  render_views

  let!(:scribe) do
    Mage.create!(admin: true,
      email: 'section-turbo-scribe@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:book) { Fabricate(:book) }
  let!(:edition) { Edition.create!(major: 1, minor: 0, patch: 0) }
  let!(:chapter) { Chapter.create!(title: 'Turbo chapter') }
  let!(:chapter_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter) }
  let!(:first_section) { Section.create!(heading: 'First section') }
  let!(:first_section_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: first_section) }
  let!(:second_section) { Section.create!(heading: 'Second section') }
  let!(:second_section_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: second_section) }

  before { sign_in scribe }

  it 'creates a section with a Turbo Stream response that refreshes its chapter frame' do
    expect do
      post :create,
           params: { table_of_content_id: chapter_table_of_content.id, section: { heading: 'Turbo section', subheading: 'A stream response' } },
           format: :turbo_stream
    end.to change(Section, :count).by(1)

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
  end

  it 'reorders sections with a Turbo Stream response that refreshes the chapter frame' do
    put :promote,
        params: { id: second_section.id, table_of_content_id: second_section_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
    expect(second_section_table_of_content.reload.ordering).to be < first_section_table_of_content.reload.ordering
  end

  it 'updates and removes sections with Turbo Stream responses' do
    patch :update,
          params: { id: first_section.id, table_of_content_id: first_section_table_of_content.id, section: { heading: 'Renamed section', subheading: 'Updated' } },
          format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")

    delete :destroy,
           params: { id: second_section.id, table_of_content_id: second_section_table_of_content.id },
           format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
  end

  it 'moves a section between chapters with Turbo Stream responses for both chapter frames' do
    next_chapter = Chapter.create!(title: 'Following chapter')
    TableOfContent.create!(book: book, edition: edition, chapter: next_chapter)

    put :delay,
        params: { id: first_section.id, table_of_content_id: first_section_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(next_chapter)}\"")
    expect(first_section_table_of_content.reload.chapter).to eq(next_chapter)
  end
end
