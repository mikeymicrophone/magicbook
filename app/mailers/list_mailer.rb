class ListMailer < ApplicationMailer
  include Resque::Mailer
  
  def suggested listed_item_id
    @listed_item = ListedItem.find listed_item_id
    @list = @listed_item.list
    @magician = @list.magician

    mail :subject => "There is a suggestion for your list, #{@list.name}",
         :to      => @magician.email,
         :from    => ENV['DELIVERY_EMAIL']
  end
end
