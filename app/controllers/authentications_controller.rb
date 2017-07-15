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
    end
    
    if @magician || @muggle
      sign_in @magician || @muggle
      redirect_to root_url, :notice => 'Signed in!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Signed out!'
  end 
end
