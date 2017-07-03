Fabricator :chapter do
  title { Faker::Hipster.sentence 3 }
  subtitle { Faker::Shakespeare.king_richard_iii_quote }
  edition { |attrs| attrs[:editions]&.first }
  book { |attrs| attrs[:edition]&.books&.last }
end

Fabricator :complete_chapter, :from => :chapter do
  editions :count => 1
end
