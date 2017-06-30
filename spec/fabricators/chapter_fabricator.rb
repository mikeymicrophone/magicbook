Fabricator(:chapter) do
  edition
  title { Faker::Hipster.sentence 3 }
  subtitle { Faker::Shakespeare.king_richard_iii }
end
