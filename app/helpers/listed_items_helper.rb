module ListedItemsHelper
  def listed_item_form list, listed_item = list.listed_items.new
    form_with :model => listed_item, :url => (listed_item.persisted? ? listed_item_path : list_listed_items_path(list)), :id => dom_id(listed_item, :form_for) do |listed_item_form|
      tag.div(:class => 'inline') do
        listed_item_form.text_area(:designation, :placeholder => 'Designation (e.g. name, title, or rank)', :style => "width: 344px; height: 30px") +
        tag.br +
        listed_item_form.text_area(:expression, :placeholder => 'Expression (e.g. card, writing, link)', :style => "width: 418px; height: 107px") +
        tag.br +
        listed_item_form.radio_button(:privacy, :draft) +
        listed_item_form.label(:privacy, :draft) +
        listed_item_form.radio_button(:privacy, :unreviewed) +
        listed_item_form.label(:privacy_unreviewed, 'public') +
        listed_item_form.radio_button(:privacy, :unreviewed_secret) +
        listed_item_form.label(:privacy_unreviewed_secret, 'just for my muggles')
      end +
      tag.div(:class => 'inline') do
        listed_item_form.collection_select(:content_id, List.all, :id, :name, {:include_blank => true}, {:id => 'listed_item_content_id'}) +
        listed_item_form.hidden_field(:content_type, :id => 'listed_item_content_type')
      end +
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
      listed_item_editing_tools_for(listed_item) +
      div_for(listed_item, :expression_of) do
        mark_up listed_item.expression
      end +
      if listed_item.content.present?
        display_list listed_item.content
      else
        ''.html_safe
      end
    end
  end
  
  def listed_item_editing_tools_for listed_item
    if current_magician == listed_item.list.magician
      div_for listed_item, :editing_tools_for do
        if listed_item.list.mode != 'randomized'
          link_to('move up', move_up_listed_item_path(listed_item, :format => :js), :method => :put, :remote => true, :class => 'list_item_ordering') + tag.br
        else
          ''.html_safe
        end +
        link_to('edit', edit_listed_item_path(listed_item, :format => :js), :remote => true, :class => 'list_item_edit_link') +
        if listed_item.list.mode != 'randomized'
          tag.br + link_to('move down', move_down_listed_item_path(listed_item, :format => :js), :method => :put, :remote => true, :class => 'list_item_ordering')
        else
          ''.html_safe
        end
      end
    else
      ''.html_safe
    end
  end
  
  def visible_items_for list
    if current_magician
      list.ordered_items
    elsif current_muggle
      list.items_for current_muggle
    else
      list.published_items
    end
  end
end
