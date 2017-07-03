Fabricator :paragraph do
  text { Faker::Friends.quote }
  section { |attrs| attrs[:sections]&.first }
  chapter { |attrs| attrs[:section]&.chapter }
  edition { |attrs| attrs[:chapter]&.edition }
  book { |attrs| attrs[:edition]&.book }
end

Fabricator :complete_paragraph, :from => :paragraph do
  sections :count => 1
  section { |attrs| attrs[:sections].first }
end
