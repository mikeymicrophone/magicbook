namespace :tagging do
  desc "Seed the system tag and editable Magic starter tag styles"
  task seed: :environment do
    tag = Tagging::SystemSeeder.new.call
    puts "Seeded #{tag.tag_context.slug}/#{tag.slug} and #{Tagging::SystemSeeder::STARTER_CONTEXTS.size} starter tag styles"
  end
end
