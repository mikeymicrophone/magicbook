module CardsHelper
  def card_display card
    div_for card do
      image_tag card.image_url
    end
  end
end
