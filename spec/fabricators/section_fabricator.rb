Fabricator :section do
  heading { Faker::Lorem.sentence }
  subheading { Faker::Lorem.sentence }
  chapter { |attrs| attrs[:chapters]&.first }
  edition { |attrs| attrs[:chapter]&.edition }
  book { |attrs| attrs[:edition]&.book }
end

Fabricator :complete_section, :from => :section do
  chapters :count => 1
end
