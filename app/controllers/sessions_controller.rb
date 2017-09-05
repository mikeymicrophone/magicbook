class SessionsController < Devise::SessionsController
  def create
    if Magician.where(:email => params[:magician][:email]).present?
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
    elsif Muggle.where(:email => params[:magician][:email]).present?
      # log in as muggle if magician account not available
      # sign_in_params = permitted_params
      # sign_in_params[:muggle] = sign_in_params[:magician]
      self.resource = Muggle.where(:email => params[:magician][:email]).first
      sign_in(:muggle, resource)
    end
    
    if resource
      if @scribe = Scribe.find_by(:email => resource.email)
        sign_in :scribe, @scribe
      end
      if @muggle = Muggle.find_by(:email => resource.email)
        sign_in :muggle, @muggle
      end
    end
    
    set_flash_message!(:notice, :signed_in)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
  
  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"]
  end
  
  def permitted_params
    params.require(:magician).permit(:email, :password, :remember_me)
  end
end
