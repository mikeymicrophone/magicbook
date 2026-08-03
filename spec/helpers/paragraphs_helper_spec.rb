require 'rails_helper'

RSpec.describe ParagraphsHelper, type: :helper do
  describe '#paragraph_form' do
    it 'keeps the Turbo submission out of the legacy Turbolinks handler' do
      html = helper.paragraph_form(TableOfContent.new(id: 1)).to_s

      expect(html).to include('data-turbo-stream="true"')
      expect(html).to include('data-turbolinks="false"')
    end
  end

  describe '#paragraph_control' do
    it 'puts an accessible edit icon below the paragraph and its citations' do
      book = Book.create!(title: 'Editor layout test', author: 'Test', version: '0.1.0', price_cents: 0)
      edition = Edition.create!(major: 0, minor: 1, patch: 0, release: 1.day.ago)
      TableOfContent.create!(book: book, edition: edition)
      chapter = Chapter.create!(title: 'Chapter')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter)
      section = Section.create!(heading: 'Section')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section)
      paragraph = Paragraph.create!(text: 'A paragraph to edit.')
      paragraph_toc = TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph)
      citation = Citation.create!(finding: 'A citation', source: 'Test source')
      TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph, citation: citation)

      html = helper.paragraph_control(paragraph_toc).to_s

      expect(html).to include('paragraph_controls')
      expect(html).to include('aria-label="Edit paragraph"')
      expect(html).to include('paragraph_edit_link')
      expect(html).to include('<img alt=""')
      expect(html).to include('toc-editor#open')
      expect(html).to include('aria-label="Add citation"')
      expect(html.index(dom_id(paragraph, :citations))).to be < html.index('paragraph_controls')
    end
  end

end
