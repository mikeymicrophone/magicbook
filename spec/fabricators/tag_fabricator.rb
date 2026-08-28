Fabricator :tag do
  tag_context
  name { Faker::Lorem.unique.word.titleize }
  slug { Faker::Lorem.unique.word.parameterize }
  kind "user"
end

Fabricator :tagging do
  tag
  taggable { Fabricate(:book) }
end
