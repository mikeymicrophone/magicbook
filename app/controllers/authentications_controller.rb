class AuthenticationsController < ApplicationController
  def facebook
    create
  end
  
  def create
    auth = request.env['omniauth.auth']
    if @identifier = Identifier.find_by(:provider => auth['provider'], :uid => auth['uid'])
      if @identifier.magician
        @magician = @identifier.magician
      elsif @identifier.muggle
        @muggle = @identifier.muggle
      end
    elsif @magician = Magician.find_by(:email => auth['info']['email'])
      @identifier = @magician.identifiers.create :provider => auth['provider'], :uid => auth['uid'], :email => auth['info']['email']
    elsif @muggle = Muggle.find_by(:email => auth['info']['email'])
      @identifier = @muggle.identifiers.create :provider => auth['provider'], :uid => auth['uid'], :email => auth['info']['email']
    elsif session[:muggling]
      @purchase = Purchase.find session[:muggling]
      if @purchase.can_invite_muggles?
        @muggle = @purchase.muggles.create :email => auth['info']['email'], :magician => @purchase.magician
        BookMailer.gifted(@purchase.id, @muggle.id, '').deliver if @muggle.valid?
      end
    end
    
    if @magician || @muggle
      sign_in @magician || @muggle
      redirect_to root_url, :notice => 'Signed in!'
    end
    
    if @magician
      if @scribe = Scribe.find_by(:email => @magician.email)
        sign_in @scribe
      end
      if @muggle = Muggle.find_by(:email => @magician.email)
        sign_in @muggle
      end
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Signed out!'
  end 
end
