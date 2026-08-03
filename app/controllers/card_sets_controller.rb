class CardSetsController < ApplicationController
  def index
    authorize! :read, CardSet

    @selected_category = params[:category].presence || 'browseable'
    @card_sets = filtered_sets.order(released_on: :desc, name: :asc).page(params[:page]).per(48)
    @category_counts = CardSet.group(:category).count
  end

  def show
    authorize! :read, CardSet

    @card_set = CardSet.find_by!(code: params[:code])
    @cards = @card_set.cards.includes(:card_concept).order(:collector_number).page(params[:page]).per(60)
  end

  private

  def filtered_sets
    return CardSet.all if @selected_category == 'all'
    return CardSet.browseable if @selected_category == 'browseable'
    return CardSet.none unless CardSet.categories.key?(@selected_category)

    CardSet.public_send(@selected_category)
  end
end
