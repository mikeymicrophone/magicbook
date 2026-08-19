class CardFunctionAssignmentsController < ApplicationController
  def create
    @card = Card.find(params[:card_id])
    authorize! :manage, @card

    card_function = CardFunction.find(card_function_assignment_params.fetch(:card_function_id))
    assignment = CardFunctionAssignment.find_or_initialize_by(
      card_concept: @card.card_concept,
      card_function: card_function
    )
    assignment.source = "manual" if assignment.new_record?
    assignment.save!

    render json: { id: card_function.id, name: card_function.name }, status: :created
  end

  private

  def card_function_assignment_params
    params.require(:card_function_assignment).permit(:card_function_id)
  end
end
