Fabricator(:section) do
  chapter
  heading { Faker::StarWars.quote }
  subheading { Faker::Space.nasa_space_craft + " launched from " + Faker::Pokemon.location }
end
