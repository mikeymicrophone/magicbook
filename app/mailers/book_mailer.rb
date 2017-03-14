class BookMailer < ApplicationMailer
  def purchased purchase
    # uploader = PdfUploader.new Book.last
    if Book.last.try(:pdf)
      # uploader.retrieve_from_store!(Book.last.pdf)
      # uploader.cache_stored_file!
      # pdf = uploader.file
      file = Book.last.pdf.file
      if file.exists?
        pdf = open(file.url).read
        attachments['How to Enjoy Magic Cards.pdf'] = pdf
      end
    end
    mail :subject => "How to Enjoy Magic Cards (your purchased ebook)",
         :to      => purchase.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
  
  def gifted
    
  end
end
