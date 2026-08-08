class BookMailer < ApplicationMailer
  def purchased purchase_id
    @purchase = Purchase.find purchase_id
    @purchase.books.each do |book|
      if book.pdf.attached?
        attachments["#{book.title}.pdf"] = book.pdf.download
      end
    end

    mail :subject => "#{@purchase.books.first.title} (your purchased e-book)",
         :to      => @purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted(purchase_id, invitation_id, note)
    @purchase = Purchase.find purchase_id
    @purchase.books.each do |book|
      if book.pdf.attached?
        attachments["#{book.title}.pdf"] = book.pdf.download
      end
    end
    
    @invitation = Invitation.find(invitation_id)
    @mage = @invitation.mage
    @note = note

    mail :subject => "#{@purchase.books.first.title} (your gifted e-book)",
         :to      => @mage.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def ramped purchase_id
    @purchase = Purchase.find purchase_id
    @mage = @purchase.mage
    @mage.ensure_authentication_token
    @purchase.books.each do |book|
      if book.pdf.attached?
        attachments["#{book.title}.pdf"] = book.pdf.download
      end
    end

    mail :subject => "#{@purchase.books.first.title} (an e-book)",
         :to      => @purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
end
