namespace :cards do
  namespace :ingest do
    
    desc 'Take all cards from the source and save them in the database'
    task :all => :environment do
      source_file = open('http://mtgjson.com/json/AllCards.json')
      if source_file
        
        source_data = JSON.parse source_file.read
        source_data.each do |card_key, card_data|
          card = Card.new
          card.name = card_data['name']
          card_data['types']&.each do |card_type|
            if card_type == 'Eaturecray'
              card_type = 'creature'
            end
            if card_type == 'Enchant'
              card_type = 'Enchantment'
              card.send "#{card_type.downcase}=", true
              break
            end
            begin
              card.send "#{card_type.downcase}=", true
            rescue
              puts "unrecognized type: #{card_type}"
              puts card_data['name']
            end
          end
          card_data['colors']&.each do |card_color|
            card.send "#{card_color.downcase}=", true
          end
          
          card.converted_mana_cost = card_data['cmc']
          card.save
        end
      end
    end
    
    desc 'Add multiverse_id and image url to existing cards'
    task :images => :environment do
      Card.find_in_batches(:batch_size => 2) do |group|
        group.each do |card|
          card_name = card.name.gsub /[\W\s]/, ''
          begin
            open("https://api.scryfall.com/cards/named?exact=#{card_name}") do |result|
              card_data = JSON.parse result.read
              card.multiverse_id = card_data['multiverse_id']
              card.image_url = card_data['image_uris']['png']
              card.save
              puts card.inspect
            end
          rescue OpenURI::HTTPError
            puts "Not found: #{card_name}"
          end
        end
        sleep 0.1
      end
    end
  end
end
