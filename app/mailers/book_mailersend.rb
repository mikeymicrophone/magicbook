class BookMailersend
  def self.purchased(purchase_id)
    ms_email = Mailersend::Email.new
    @purchase = Purchase.find purchase_id
    @purchase.books.each do |book|
      if book.pdf&.file&.exists?
        ms_email.add_attachment filename: "#{book.title}.pdf", content: Base64.strict_encode64(URI.open(book.pdf.file.url).read), disposition: 'attachment'
      end
    end
    
    ms_email.add_subject "#{@purchase.books.first.title} (your purchased e-book)"
    ms_email.add_recipients 'email' => @purchase.email
    ms_email.add_from 'email' => ENV['DELIVERY_EMAIL'], 'name' => 'Ways We Mage'
    
    invite_link = "https://wayswemage.com/muggles/invite?purchase_id=#{purchase_id}"
    
    ms_email.add_text("Thank you very much for your purchase!  I hope you enjoy the ebook and get a kick out of the world's greatest game (Magic).
Your purchase includes a license to gift this book to four muggles.  You may have already entered some.  If you want to add more, be sure to return to this page within the next 72 hours: #{invite_link}
Your purchase also ensures access for you and your four muggles to all future updates of the book.
Last but not least, you can make lists.  They can be public, or just for your muggles.
Thank you for supporting Ways We Mage.  If and when you would like to write a book, contact us.
-Mikey Microphone")
    ms_email.add_html("<p>Thank you very much for your purchase!  I hope you enjoy the ebook and get a kick out of the world's greatest game (Magic).</p>
<p>Your purchase includes a license to gift this book to four muggles.  You may have already entered some.  If you want to add more, be sure to return to this page within the next 72 hours: #{invite_link}</p>
<p>Your purchase also ensures access for you and your four muggles to all future updates of the book.</p>
<p>Last but not least, you can make lists.  They can be public, or just for your muggles.</p>
<p>Thank you for supporting Ways We Mage.  If and when you would like to write a book, contact us.</p>
<p>-Mikey Microphone</p>")

    ms_email
  end
end
