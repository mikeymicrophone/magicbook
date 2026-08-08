class MagicLinkMailer < ApplicationMailer
  def sign_in(mage, token)
    @magic_link = consume_magic_link_url(token: token)
    mail(to: mage.email, subject: 'Your Ways We Mage sign-in link')
  end
end
