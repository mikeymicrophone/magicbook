class MagesController < ApplicationController
  before_action :require_admin!

  def index
    @mages = Mage.order(:email)
  end

  def ramp
    purchase = Purchase.create!(ramp: true, email: params[:email])
    BookMailer.ramped(purchase.id).deliver_later
    redirect_to mages_path, notice: 'Access invitation sent.'
  end

  private

  def require_admin!
    authenticate_mage!
    authorize! :manage, :all
  end
end
