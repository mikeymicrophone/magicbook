class PasswordsController < Devise::PasswordsController
  def establish
    @mage = Mage.reset_password_by_token(params.require(:mage).permit(:reset_password_token, :password, :password_confirmation))

    if @mage.errors.empty?
      @mage.update!(must_set_password: false)
      sign_in @mage
      redirect_to after_sign_in_path_for(@mage)
    else
      render 'confirmations/establish_access', status: :unprocessable_entity
    end
  end
end
