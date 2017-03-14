class BookMailer < ApplicationMailer
  def purchased purchase
    if Book.last.try(:pdf).try(:file).try(:exists?)
      pdf = Book.last.pdf
      file = open(pdf.file.url)
      attachments['How to Enjoy Magic Cards.pdf'] = file.read
    end
    mail :subject => "How to Enjoy Magic Cards (your purchased ebook)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted
    
  end
end
