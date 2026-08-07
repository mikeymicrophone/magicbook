require 'rails_helper'

RSpec.describe CitationsHelper, type: :helper do
  describe '#citation_form' do
    it 'requests a Turbo Stream response' do
      html = helper.citation_form(TableOfContent.new(id: 1)).to_s

      expect(html).to include('data-turbo-stream="true"')
    end
  end

  describe '#edit_controls_for_citation' do
    it 'guards each inline edit link against repeated clicks' do
      book = Book.create!(title: 'Citation control test', author: 'Test', version: '0.1.0', price_cents: 0)
      edition = Edition.create!(major: 0, minor: 1, patch: 0, release: 1.day.ago)
      TableOfContent.create!(book: book, edition: edition)
      chapter = Chapter.create!(title: 'Chapter')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter)
      section = Section.create!(heading: 'Section')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section)
      paragraph = Paragraph.create!(text: 'A paragraph')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph)
      citation = Citation.create!(finding: 'A citation', source: 'Test source')
      table_of_content = TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph, citation: citation)

      expect(helper.edit_controls_for_citation(table_of_content).to_s).to include('toc-editor#open')
    end
  end

end
