Fabricator :citation do
  source { Faker::Educator.university }
  finding { Faker::Ancient.god }
  paragraph { |attrs| attrs[:paragraphs]&.first }
  section { |attrs| attrs[:paragraph]&.section }
  chapter { |attrs| attrs[:section]&.chapter }
  edition { |attrs| attrs[:chapter]&.edition }
  book { |attrs| attrs[:edition]&.book }
end

Fabricator :complete_citation, :from => :citation do
  paragraphs :count => 1
  paragraph { |attrs| attrs[:paragraphs].first }
end
