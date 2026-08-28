Fabricator :tag_context do
  name { Faker::Lorem.unique.word.titleize }
  slug { Faker::Lorem.unique.word.parameterize }
  kind "user"
end

Fabricator :format_tag_context, from: :tag_context do
  name "Format"
  slug "format"
end

Fabricator :strategy_tag_context, from: :tag_context do
  name "Strategy"
  slug "strategy"
end

Fabricator :power_level_tag_context, from: :tag_context do
  name "Power level"
  slug "power-level"
end

Fabricator :era_tag_context, from: :tag_context do
  name "Era"
  slug "era"
end
