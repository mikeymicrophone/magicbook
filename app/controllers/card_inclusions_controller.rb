class CardInclusionsController < ApplicationController
  def new
    @piece = ListedItem.find params[:listed_item_id]
    @card_inclusion = CardInclusion.new
  end
  
  def create
    @card = Card.find_by :name => card_inclusion_params[:card_name]
    @card_inclusion = CardInclusion.new card_inclusion_params
    @card_inclusion.card = @card
    @card_inclusion.save if @card_inclusion.piece.magician == current_magician
  end
  
  def card_inclusion_params
    params.require(:card_inclusion).permit :card_id, :card_name, :piece_id, :piece_type
  end
end
