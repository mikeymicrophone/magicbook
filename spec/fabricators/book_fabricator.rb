Fabricator :book do
  title { Faker::Book.title }
  version { "#{rand(10)}.#{rand(15)}.#{rand(7)}" }
  pdf { Faker::File.file_name }
  author { Faker::Book.author }
end
