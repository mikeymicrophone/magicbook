Fabricator(:citation) do
  paragraph
  source { Faker::Educator.university }
  finding { Faker::Ancient.god }
end
