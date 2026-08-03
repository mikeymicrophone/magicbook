Fabricator :book do
  title { Faker::Book.title }
  version { "#{rand(10)}.#{rand(15)}.#{rand(7)}" }
  author { Faker::Book.author }
end
