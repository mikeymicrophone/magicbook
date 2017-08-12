class BookMailer < ApplicationMailer
  include Resque::Mailer
  
  def purchased purchase_id
    @purchase = Purchase.find purchase_id
    @purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end

    mail :subject => "#{@purchase.books.first.title} (your purchased e-book)",
         :to      => @purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted purchase_id, muggle_id, note
    @purchase = Purchase.find purchase_id
    @purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end
    
    @muggle = Muggle.find muggle_id
    @note = note

    mail :subject => "#{@purchase.books.first.title} (your gifted e-book)",
         :to      => @muggle.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def ramped purchase_id
    @purchase = Purchase.find purchase_id
    @magician = @purchase.magician
    @magician.ensure_authentication_token
    @purchase.books.each do |book|
      if book.pdf&.file&.exists?
        attachments["#{book.title}.pdf"] = open(book.pdf.file.url).read
      end
    end

    mail :subject => "#{@purchase.books.first.title} (an e-book)",
         :to      => @purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
end
