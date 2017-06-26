class BookMailer < ApplicationMailer
  def purchased purchase
    purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end

    mail :subject => "How to Enjoy Magic Cards (your purchased ebook)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted
    
  end
end
