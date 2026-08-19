require 'rails_helper'

RSpec.describe TableOfContent, type: :model do
  describe 'published edition isolation' do
    it 'keeps an earlier published table of contents unchanged when a later edition is reordered' do
      book = Book.create!(title: 'Edition history', author: 'Test', version: '0.1.0', price_cents: 0)
      first_edition = Fabricate(:edition_for_book, book: book, major: 0, minor: 1, patch: 0)
      first_chapter = Fabricate(:chapter)
      second_chapter = Fabricate(:chapter)

      TableOfContent.create!(book: book, edition: first_edition, chapter: first_chapter)
      TableOfContent.create!(book: book, edition: first_edition, chapter: second_chapter)

      second_edition = first_edition.release_for!(book, at: Time.utc(2026, 8, 6, 12))
      second_edition.release_for!(book, at: Time.utc(2026, 8, 7, 12))

      second_edition_tocs = book.table_of_contents.in_edition(second_edition).chapterish.ordered
      second_edition_tocs.find_by!(chapter: second_chapter).promote!

      expect(first_edition.reload.release).to eq(Time.utc(2026, 8, 6, 12))
      expect(second_edition.reload.release).to eq(Time.utc(2026, 8, 7, 12))
      expect(book.table_of_contents.in_edition(first_edition).chapterish.ordered.pluck(:chapter_id)).to eq([
        first_chapter.id,
        second_chapter.id
      ])
      expect(book.table_of_contents.in_edition(second_edition).chapterish.ordered.pluck(:chapter_id)).to eq([
        second_chapter.id,
        first_chapter.id
      ])
    end
  end
end
