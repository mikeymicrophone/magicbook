Fabricator :edition do
  major { 0 }
  minor { 1 }
  patch { 0 }
  note { Faker::Lorem.paragraph }
  release { nil }
end

Fabricator :edition_for_book, from: :edition do
  transient :book

  after_create do |edition, transients|
    book = transients[:book] || Fabricate(:book, version: edition.version)
    TableOfContent.create!(book: book, edition: edition)
  end
end

Fabricator :release_ready_edition, from: :edition do
  transient :book

  after_create do |edition, transients|
    book = transients[:book] || Fabricate(:book, version: edition.version)
    TableOfContent.create!(book: book, edition: edition)

    chapter = Fabricate(:chapter)
    TableOfContent.create!(book: book, edition: edition, chapter: chapter)

    section = Fabricate(:section)
    TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section)

    paragraph = Fabricate(:paragraph)
    TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph)

    citation = Fabricate(:citation)
    TableOfContent.create!(book: book, edition: edition, chapter: chapter, section: section, paragraph: paragraph, citation: citation)
  end
end
