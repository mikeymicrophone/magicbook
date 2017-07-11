class AuthenticationsController < ApplicationController
  def facebook
    create
  end
  
  def create
    Rails.logger.info "Omniauth parameters: #{request.env['omniauth.auth']}"
    auth = request.env['omniauth.auth']
    if @identifier = Identifier.find_by(:provider => auth['provider'], :uid => auth['uid'])
      @magician = @identifier.magician
    elsif @magician = Magician.find_by(:email => auth['info']['email'])
      @identity = @magician.identities.create :provider => auth['provider'], :uid => auth['uid'], :email => auth['info']['email']
    end
    
    if @magician
      sign_in @magician
      redirect_to root_url, :notice => 'Signed in!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Signed out!'
  end 
end
