class CardsController < ApplicationController
  def show
    @card = Card.includes(:card_set, :card_concept).find(params[:id])
    authorize! :read, @card

    @lists = @card.lists
      .merge(List.published)
      .merge(ListedItem.published)
      .distinct
      .order(:name)
  end
end
