class CardFunctionsController < ApplicationController
  def index
    authorize! :read, CardFunction

    @html_title = "Card functions"
    @card_functions = CardFunction.includes(:parents, :children).order(:name)
    @direct_counts = CardFunctionAssignment.group(:card_function_id).count
    @inclusive_counts = @card_functions.index_with do |card_function|
      card_function.card_concepts_including_descendants.count
    end
  end

  def show
    @card_function = CardFunction.includes(:parents, :children).find_by!(slug: params[:slug])
    authorize! :read, @card_function

    @html_title = @card_function.name
    @card_concepts = @card_function.card_concepts_including_descendants
      .order(:name)
      .page(params[:page])
      .per(48)
    @preferred_printings = preferred_printings_for(@card_concepts)
  end

  private

  def preferred_printings_for(card_concepts)
    Card.where(card_concept_id: card_concepts.map(&:id))
      .includes(:card_set)
      .order(:released_on, :id)
      .group_by(&:card_concept_id)
      .transform_values { |printings| printings.find(&:preferred?) || printings.first }
  end
end
