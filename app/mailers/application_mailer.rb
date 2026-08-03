class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('DELIVERY_EMAIL', 'Ways We Mage <hello@mail.wayswemage.com>')
  layout 'mailer'
end
