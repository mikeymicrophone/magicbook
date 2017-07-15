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
    
    Rails.logger.info @muggle_1.errors.full_messages
    
    BookMailer.gifted(@purchase, @muggle_1).deliver if @muggle_1.valid?
    BookMailer.gifted(@purchase, @muggle_2).deliver if @muggle_2.valid?
    BookMailer.gifted(@purchase, @muggle_3).deliver if @muggle_3.valid?
    BookMailer.gifted(@purchase, @muggle_4).deliver if @muggle_4.valid?
  end
end
