namespace :cards do
  namespace :ingest do
    
    desc 'Take all cards from the source and save them in the database'
    task :all => :environment do
      puts 'accessing card file'
      json_url = 'https://mtgjson.com/api/v5/AtomicCards.json'
      source_file = URI.open json_url
      puts 'loaded card file'
      if source_file
        
        source_data = JSON.parse source_file.read
        source_data['data'].each do |card_key, card_data_array|
          begin
            card_data = card_data_array.first
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
              color = {'W' => 'white', 'U' => 'blue', 'B' => 'black', 'R' => 'red', 'G' => 'green'}[card_color]
              card.send "#{color}=", true
            end
            puts card_data['name']
            card.converted_mana_cost = card_data['manaValue']
            card.save

          rescue StandardError => e
            puts e
          end
        end
      end
    end
    
    task :set, [:set_abbreviation] => :environment do |t, args|
      set_abbreviation = args[:set_abbreviation]
      puts "accessing set file"
      json_url = "https://mtgjson.com/api/v5/#{set_abbreviation}.json"
      source_file = URI.open json_url
      puts 'loaded card file'
      if source_file
        
        source_data = JSON.parse source_file.read
        source_data['data']['cards'].each do |card_data|
          begin
            # card_data = card_data_array.first
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
              color = {'W' => 'white', 'U' => 'blue', 'B' => 'black', 'R' => 'red', 'G' => 'green'}[card_color]
              card.send "#{color}=", true
            end
            puts card_data['name']
            card.converted_mana_cost = card_data['manaValue']
            card.save

          rescue StandardError => e
            puts e
          end
        end
      end
    end
    
    desc 'Add multiverse_id and image url to existing cards'
    task :images => :environment do
      Card.unmultiversed.find_in_batches(:batch_size => 2) do |group|
        group.each do |card|
          puts card.inspect
          begin
            card_name = card.name.gsub /[\W\s]/, ''
          rescue
            
          end
          if card_name
            begin
              URI.open("https://api.scryfall.com/cards/named?exact=#{card_name}") do |result|
                card_data = JSON.parse result.read
                card.multiverse_id = card_data['multiverse_ids'].first
                if card_data['image_uris']
                  card.image_url = card_data['image_uris']['png']
                elsif card_data['card_faces']
                  begin
                    if card.name =~ /(.*)\/\//
                      front_face_name = $1.chomp
                    
                    else
                      face = card_data['card_faces'].select { |face| face['name'] == card.name }.first
                      card.image_url = face['image_uris']['png']
                    end
                  rescue NoMethodError
                    puts "Not matched faces: #{card.name}"
                  end
                end
                card.save
                puts card.inspect
              end
            rescue OpenURI::HTTPError
              puts "Not found: #{card_name}"
            end
          end
        end
        sleep 0.1
      end
    end
  end
end
