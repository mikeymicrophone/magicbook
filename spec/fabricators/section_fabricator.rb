Fabricator :section do
  heading { Faker::StarWars.quote }
  subheading { Faker::Space.nasa_space_craft + " launched from " + Faker::Pokemon.location }
  chapter { |attrs| attrs[:chapters]&.first }
  edition { |attrs| attrs[:chapter]&.edition }
  book { |attrs| attrs[:edition]&.book }
end

Fabricator :complete_section, :from => :section do
  chapters :count => 1
end
