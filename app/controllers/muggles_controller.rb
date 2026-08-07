class MugglesController < ApplicationController
  load_and_authorize_resource
  
  def invite
    @purchase = Purchase.find params[:purchase_id]
  end
  
  def submit
    @purchase = Purchase.find params[:purchase_id]
    return redirect_to(root_url) unless @purchase.magician == current_magician

    @muggles = (1..4).map do |index|
      Muggle.create(email: params["email_#{index}"], purchase_id: params[:purchase_id], magician: current_magician)
    end

    @muggles.select(&:valid?).each do |muggle|
      BookMailer.gifted(@purchase.id, muggle.id, params[:message]).deliver_later
    end

    if @muggles.all? { |muggle| muggle.persisted? || muggle.email.blank? }
      redirect_to invite_muggles_path(purchase_id: @purchase), notice: 'Your invitations have been sent.'
    else
      render :invite, status: :unprocessable_entity
    end
  end
  
  def index
    @muggles = Muggle.recent
  end
  
  def show
    @muggle = Muggle.find params[:id]
  end
end
