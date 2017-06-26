Fabricator :purchase do
  email { Faker::Internet.email }
  stripe_token { Faker::Crypto.md5 }
end
