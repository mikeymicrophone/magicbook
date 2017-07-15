class MugglesController < ApplicationController
  def invite
    
  end
  
  def submit
    @purchase = Purchase.find params[:purchase_id]
    redirect_to root_url unless @purchase.magician == current_magician
    @muggle_1 = Muggle.create :email => params[:email_1], :purchase_id => params[:purchase_id], :magician => current_magician
    @muggle_2 = Muggle.create :email => params[:email_2], :purchase_id => params[:purchase_id], :magician => current_magician
    @muggle_3 = Muggle.create :email => params[:email_3], :purchase_id => params[:purchase_id], :magician => current_magician
    @muggle_4 = Muggle.create :email => params[:email_4], :purchase_id => params[:purchase_id], :magician => current_magician
    
    BookMailer.gifted(@purchase.id, @muggle_1.id).deliver if @muggle_1.valid?
    BookMailer.gifted(@purchase.id, @muggle_2.id).deliver if @muggle_2.valid?
    BookMailer.gifted(@purchase.id, @muggle_3.id).deliver if @muggle_3.valid?
    BookMailer.gifted(@purchase.id, @muggle_4.id).deliver if @muggle_4.valid?
  end
end
