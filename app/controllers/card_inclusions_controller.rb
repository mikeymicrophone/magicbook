class CardInclusionsController < ApplicationController
  def new
    @piece = ListedItem.find params[:listed_item_id]
    @card_inclusion = CardInclusion.new
  end
  
  def create
    @card = Card.lookup_by_name(card_inclusion_params[:card_name])
    
    unless @card
      card = Card.new :name => card_inclusion_params[:card_name]
      begin
        URI.open("https://api.scryfall.com/cards/named?exact=#{card_inclusion_params[:card_name]}") do |result|
          card_data = JSON.parse result.read
          card.multiverse_id = card_data['multiverse_ids']&.first
          card.scryfall_id = card_data['id']
          card.card_concept.update!(oracle_id: card_data['oracle_id']) if card.card_concept && card_data['oracle_id'].present?
          card.image_url = card_data.dig('image_uris', 'png') || card_data.dig('card_faces', 0, 'image_uris', 'png')
          card.save if card.image_url.present?
          puts card.inspect
        end
        @card = card if card.persisted?
      rescue OpenURI::HTTPError
        puts "Not found: #{card_inclusion_params[:card_name]}"
      end
    end
    
    @card_inclusion = CardInclusion.new card_inclusion_params
    @card_inclusion.card = @card
    @card_inclusion.save if @card_inclusion.piece.mage == current_mage
    @piece = @card_inclusion.piece

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: list_path(@piece.list) }
    end
  end
  
  def card_inclusion_params
    params.require(:card_inclusion).permit :card_id, :card_name, :piece_id, :piece_type
  end
end
