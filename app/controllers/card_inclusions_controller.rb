class CardInclusionsController < ApplicationController
  def new
    @piece = ListedItem.find params[:listed_item_id]
    @card_inclusion = CardInclusion.new
  end
  
  def create
    @card = Card.find_by :name => card_inclusion_params[:card_name]
    
    unless @card
      card = Card.new :name => card_inclusion_params[:card_name]
      begin
        open("https://api.scryfall.com/cards/named?exact=#{card_inclusion_params[:card_name]}") do |result|
          card_data = JSON.parse result.read
          card.multiverse_id = card_data['multiverse_id']
          card.image_url = card_data['image_uris']['png']
          card.save if card.image_url.present?
          puts card.inspect
        end
        @card = card if card.persisted?
      rescue OpenURI::HTTPError
        puts "Not found: #{card_name}"
      end
    end
    
    @card_inclusion = CardInclusion.new card_inclusion_params
    @card_inclusion.card = @card
    @card_inclusion.save if @card_inclusion.piece.magician == current_magician
  end
  
  def card_inclusion_params
    params.require(:card_inclusion).permit :card_id, :card_name, :piece_id, :piece_type
  end
end
