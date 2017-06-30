Fabricator(:paragraph) do
  section
  text { Faker::Friends.quote }
end
