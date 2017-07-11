class AuthenticationsController < ApplicationController
  def facebook
    create
  end
  
  def create
    Rails.logger.info "Omniauth parameters: #{request.env['omniauth.auth']}"
    auth = request.env['omniauth.auth']
    @magician = Magician.find_by_provider_and_uid(auth['provider'], auth['uid'])
    @muggle = Muggle.find_by :provider => auth['provider'], :uid => auth[uid] unless @magician
    
    @magician = Magician.create_with_omniauth auth unless @magician || @muggle
    
    if @magician
      sign_in @magician
    elsif @muggle
      sign_in @muggle
    end
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Signed out!'
  end 
end
