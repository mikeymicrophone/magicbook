module ListedItemsHelper
  def listed_item_form list
    form_with :model => list.listed_items.new, :url => list_listed_items_path(list) do |listed_item_form|
      listed_item_form.text_area(:designation, :placeholder => 'Designation (e.g. name, title, or rank)', :style => "width: 344px; height: 30px") +
      tag.br +
      listed_item_form.text_area(:expression, :placeholder => 'Expression (e.g. card, writing, link)', :style => "width: 418px; height: 107px") +
      tag.br +
      listed_item_form.radio_button(:privacy, :draft) +
      listed_item_form.label(:privacy, :draft) +
      listed_item_form.radio_button(:privacy, :unreviewed) +
      listed_item_form.label(:privacy_unreviewed, 'public') +
      listed_item_form.radio_button(:privacy, :unreviewed_secret) +
      listed_item_form.label(:privacy_unreviewed_secret, 'just for my muggles') +
      tag.br +
      listed_item_form.submit('Ready') +
      tag.div(:class => 'instructions') do
        "You can use Markdown for formatting, links, and HTML.  Submissions are subject to approval.  Present material that is legal and tasteful."
      end
    end
  end
  
  def listed_item_display listed_item
    div_for listed_item do
      if listed_item.list.mode == 'numbered'
        div_for listed_item, :number_of do
          listed_item.ordering.to_s
        end
      else
        ''.html_safe
      end +
      div_for(listed_item, :designation_of) do
        mark_up listed_item.designation
      end +
      div_for(listed_item, :expression_of) do
        mark_up listed_item.expression
      end +
      if listed_item.content.present?
        link_to listed_item.content.id, listed_item.content
      else
        ''.html_safe
      end
    end
  end
end