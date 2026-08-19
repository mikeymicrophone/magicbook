require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe '#release_for!' do
    let(:book) { Book.create!(title: 'Release test', author: 'Test', version: '0.1.0', price_cents: 0) }
    let(:edition) { Fabricate(:edition_for_book, book: book, major: 0, minor: 1, patch: 0) }

    it 'releases an empty edition and creates one editable successor' do
      successor = edition.release_for!(book, at: Time.utc(2026, 8, 8, 12))

      expect(edition.reload.release).to eq(Time.utc(2026, 8, 8, 12))
      expect(book.reload.version).to eq('0.1.0')
      expect(successor).to have_attributes(major: 0, minor: 2, patch: 0, release: nil)
      expect(book.editions.where(id: successor.id)).to exist
    end

    it 'releases a complete factory blueprint into a usable next edition' do
      edition = Fabricate(:release_ready_edition, book: book, major: 0, minor: 1, patch: 0)

      successor = edition.release_for!(book)

      expect(book.reload.current_edition).to eq(edition)
      expect(successor.release).to be_nil
      expect(successor.chapters).to contain_exactly(edition.chapters.first)
      expect(successor.sections).to contain_exactly(edition.sections.first)
      expect(successor.paragraphs).to contain_exactly(edition.paragraphs.first)
      expect(successor.citations).to contain_exactly(edition.citations.first)
    end

    it 'does not release the same edition twice or create another successor' do
      edition.release_for!(book)

      expect { edition.release_for!(book) }.to raise_error(Edition::AlreadyReleasedError)
      expect(book.editions.where(major: 0, minor: 2, patch: 0).count).to eq(1)
    end

    it 'does not release when the next minor edition already exists' do
      successor = Edition.create!(major: 0, minor: 2, patch: 0)
      TableOfContent.create!(book: book, edition: successor)

      expect { edition.release_for!(book) }.to raise_error(Edition::SuccessorAlreadyExistsError)
      expect(edition.reload.release).to be_nil
      expect(book.reload.version).to eq('0.1.0')
    end

  end

end
