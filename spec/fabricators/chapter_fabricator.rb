Fabricator :chapter do
  title { Faker::Lorem.sentence }
  subtitle { Faker::Lorem.sentence }
  edition { |attrs| attrs[:editions]&.first }
  book { |attrs| attrs[:edition]&.books&.last }
end

Fabricator :complete_chapter, :from => :chapter do
  editions :count => 1
end
