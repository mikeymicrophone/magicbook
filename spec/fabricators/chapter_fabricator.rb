Fabricator(:chapter) do
  edition
  title { Faker::Hipster.words }
  subtitle { Faker::Shakespeare.king_richard_iii }
end
