class PasswordsController < Devise::PasswordsController
  def establish
    @magician = Magician.reset_password_by_token params[:magician]
    sign_in @magician
    redirect_to after_sign_in_path_for(@magician)
  end
end
