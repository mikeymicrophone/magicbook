module ListedItemsHelper
  def listed_item_form list
    form_with :model => list.listed_items.new, :url => list_listed_items_path(list) do |listed_item_form|
      listed_item_form.text_area(:designation, :placeholder => 'Designation (e.g. name, title, or rank)', :style => "width: 344px; height: 30px") +
      tag.br +
      listed_item_form.text_area(:expression, :placeholder => 'Expression (e.g. card, writing, link)', :style => "width: 418px; height: 107px") +
      tag.br +
      listed_item_form.submit('Ready')
    end
  end
  
  def listed_item_display listed_item
    div_for listed_item do
      div_for(listed_item, :designation_of) do
        mark_up listed_item.designation
      end +
      if listed_item.expression?
        div_for listed_item, :expression_of do
          mark_up listed_item.expression
        end
      end +
      if listed_item.content.present?
        link_to listed_item.content.id, listed_item.content rescue nil
      end
    end
  end
end
