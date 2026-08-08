class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    mage = Mage.from_google_oauth!(request.env.fetch('omniauth.auth'))
    set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    sign_in_and_redirect mage, event: :authentication
  rescue ArgumentError, ActiveRecord::RecordInvalid
    redirect_to new_mage_session_path, alert: 'Google sign-in could not verify your email address.'
  end

  def failure
    redirect_to new_mage_session_path, alert: 'Google sign-in was cancelled or could not be completed.'
  end
end
