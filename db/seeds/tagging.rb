tag = Tagging::SystemSeeder.new.call

puts "Seeded #{tag.tag_context.slug}/#{tag.slug}"
