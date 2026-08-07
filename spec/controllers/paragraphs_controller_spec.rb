require 'rails_helper'

RSpec.describe ParagraphsController, type: :controller do
  render_views

  let!(:scribe) do
    Scribe.create!(
      email: 'paragraph-turbo-scribe@example.com',
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
  let!(:first_paragraph) { Paragraph.create!(text: 'First paragraph') }
  let!(:first_paragraph_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: first_section, paragraph: first_paragraph) }
  let!(:second_paragraph) { Paragraph.create!(text: 'Second paragraph') }
  let!(:second_paragraph_table_of_content) { TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: first_section, paragraph: second_paragraph) }

  before { sign_in scribe }

  it 'reorders paragraphs with a Turbo Stream response that refreshes the chapter frame' do
    put :promote,
        params: { id: second_paragraph.id, table_of_content_id: second_paragraph_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
    expect(second_paragraph_table_of_content.reload.ordering).to be < first_paragraph_table_of_content.reload.ordering
  end

  it 'moves a paragraph to the next section with a Turbo Stream response' do
    put :delay,
        params: { id: first_paragraph.id, table_of_content_id: first_paragraph_table_of_content.id },
        format: :turbo_stream

    expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    expect(response.body).to include("target=\"#{ActionView::RecordIdentifier.dom_id(chapter)}\"")
    expect(first_paragraph_table_of_content.reload.section).to eq(second_section)
  end
end
