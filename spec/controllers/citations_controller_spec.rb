require 'rails_helper'

RSpec.describe CitationsController, type: :controller do
  render_views

  let!(:scribe) do
    Mage.create!(admin: true,
      email: 'citation-turbo-scribe@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:book) { Fabricate(:book) }
  let!(:edition) { Edition.create!(major: 1, minor: 0, patch: 0) }
  let!(:chapter) { Chapter.create!(title: 'Turbo chapter') }
  let!(:chapter_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter) }
  let!(:section) { Section.create!(heading: 'Turbo section') }
  let!(:section_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section) }
  let!(:paragraph) { Paragraph.create!(text: 'Turbo paragraph') }
  let!(:paragraph_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph) }
  let!(:first_citation) { Citation.create!(finding: 'First citation') }
  let!(:first_citation_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph, citation: first_citation) }
  let!(:second_citation) { Citation.create!(finding: 'Second citation') }
  let!(:second_citation_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph, citation: second_citation) }

  before { sign_in scribe }

  it 'reorders citations with a Turbo Stream response that refreshes the chapter frame' do
    put :promote,
        params: { id: second_citation.id, table_of_content_id: second_citation_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
    expect(second_citation_table_of_content.reload.ordering).to be < first_citation_table_of_content.reload.ordering
  end
end
