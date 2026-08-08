class MagicLinksController < ApplicationController
  def new
  end

  def create
    mage = Mage.find_by(email: params.require(:email).to_s.strip.downcase)
    token = mage&.issue_magic_link!
    MagicLinkMailer.sign_in(mage, token).deliver_later if token.present?

    redirect_to new_magic_link_path, notice: 'If an account exists for that email, a sign-in link is on its way.'
  end

  def show
    response.set_header('Cache-Control', 'no-store')
    response.set_header('Referrer-Policy', 'no-referrer')

    if (mage = Mage.consume_magic_link(params[:token]))
      sign_in mage
      redirect_to after_sign_in_path_for(mage)
    else
      redirect_to new_magic_link_path, alert: 'That sign-in link is invalid or has expired.'
    end
  end
end
