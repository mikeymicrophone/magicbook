Fabricator :section do
  chapters :count => 1
  heading { Faker::StarWars.quote }
  subheading { Faker::Space.nasa_space_craft + " launched from " + Faker::Pokemon.location }
end
