class MagiciansController < ApplicationController
  def index
    @magicians = Magician.all
  end
  
  def ramp
    @purchase = Purchase.create :ramp => true, :email => params[:email]
    BookMailer.ramped(@purchase.id).deliver
  end
end
