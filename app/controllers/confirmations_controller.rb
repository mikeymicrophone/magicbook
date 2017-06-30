class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.needs_access_technique?
      resource.send(:set_reset_password_token)
      redirect_to :action => :establish_access, :magician_id => resource.id
    elsif resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end
  
  def establish_access
    @magician = Magician.find params[:magician_id]
  end
end
