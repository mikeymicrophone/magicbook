result = CardCatalog::StandardEnvironmentSeeder.new.call

puts "Seeded #{result[:format].name}: #{result[:sets]} sets, " \
  "#{result[:concepts]} card concepts, #{result[:assignments]} function assignments"
