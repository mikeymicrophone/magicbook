class BookMailer < ApplicationMailer
  def purchased purchase
    purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end
    
    @purchase = purchase

    mail :subject => "Ways We Enjoy Magic Cards (your purchased e-book)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted purchase, muggle
    purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end

    mail :subject => "Ways We Enjoy Magic Cards (your gifted e-book)",
         :to      => muggle.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
end
