class BookMailer < ApplicationMailer
  def purchased purchase
    uploader = PdfUploader.new Book.last
    if Book.last.try(:pdf)
      pdf = uploader.retrieve_from_store!(Book.last.pdf)
      attachments['How to Enjoy Magic Cards.pdf'] = pdf
    end
    mail :subject => "How to Enjoy Magic Cards (your purchased ebook)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted
    
  end
end
