class PasskeysController < ApplicationController
  before_action :authenticate_mage!, only: [:registration_options, :register]

  def registration_options
    user_handle = current_mage.ensure_webauthn_user_handle!
    options = WebAuthn::Credential.options_for_create(
      user: { id: user_handle, name: current_mage.email, display_name: current_mage.email },
      exclude: current_mage.passkeys.pluck(:external_id),
      authenticator_selection: { resident_key: 'required', user_verification: 'required' }
    )
    session[:passkey_registration_challenge] = options.challenge
    no_store!
    render json: options
  end

  def register
    credential = WebAuthn::Credential.from_create(credential_params)
    credential.verify(session.delete(:passkey_registration_challenge), user_verification: true)
    current_mage.passkeys.create!(
      external_id: credential.id,
      public_key: credential.public_key,
      sign_count: credential.sign_count,
      transports: Array(credential.response.transports)
    )
    no_store!
    render json: { ok: true }
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid, ActionController::ParameterMissing
    render json: { error: 'The passkey could not be registered.' }, status: :unprocessable_entity
  end

  def authentication_options
    options = WebAuthn::Credential.options_for_get(user_verification: 'required')
    session[:passkey_authentication_challenge] = options.challenge
    no_store!
    render json: options
  end

  def authenticate
    credential = WebAuthn::Credential.from_get(credential_params)
    passkey = Passkey.find_by!(external_id: credential.id)
    credential.verify(
      session.delete(:passkey_authentication_challenge),
      public_key: passkey.public_key,
      sign_count: passkey.sign_count,
      user_verification: true
    )
    passkey.update!(sign_count: credential.sign_count, last_used_at: Time.current)
    sign_in passkey.mage
    no_store!
    render json: { ok: true, redirect_to: after_sign_in_path_for(passkey.mage) }
  rescue WebAuthn::Error, ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid, ActionController::ParameterMissing
    render json: { error: 'The passkey could not be verified.' }, status: :unprocessable_entity
  end

  private

  def credential_params
    params.require(:credential).permit!.to_h
  end

  def no_store!
    response.set_header('Cache-Control', 'no-store')
  end
end
