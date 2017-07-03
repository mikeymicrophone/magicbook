Fabricator :chapter do
  editions :count => 1
  title { Faker::Hipster.sentence 3 }
  subtitle { Faker::Shakespeare.king_richard_iii_quote }
end
