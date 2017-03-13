class BookMailer < ApplicationMailer
  def purchased purchase
    mail :subject => "How to Enjoy Magic Cards (your purchased ebook)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
         # remember to include the attachment
  end
  
  def gifted
    
  end
end
