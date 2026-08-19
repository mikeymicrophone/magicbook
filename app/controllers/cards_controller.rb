class CardsController < ApplicationController
  def show
    @card = Card.includes(:card_set, card_concept: :card_functions).find(params[:id])
    authorize! :read, @card

    @role_options = CardFunction.includes(:parents).order(:name).select { |card_function| card_function.parents.empty? }

    @lists = @card.lists
      .merge(List.published)
      .merge(ListedItem.published)
      .distinct
      .order(:name)
  end
end
