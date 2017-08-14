module ListedItemsHelper
  def listed_item_form list, listed_item = list.listed_items.new
    form_with :model => listed_item, :url => (listed_item.persisted? ? listed_item_path : list_listed_items_path(list)), :id => dom_id(listed_item, :form_for), :class => 'form_for_listed_item' do |listed_item_form|
      tag.div do
        tag.div(:class => 'inline') do
          listed_item_form.text_area(:designation, :placeholder => 'Designation (e.g. name, title, or rank)', :id => 'listed_item_designation') +
          tag.br +
          listed_item_form.text_area(:expression, :placeholder => 'Expression (e.g. card, writing, link)', :id => 'listed_item_expression')
        end +
        tag.div(:class => 'inline') do
          tag.div do
            'To put a list in this item, select it here:'
          end +
          listed_item_form.collection_select(:content_id, List.alphabetical, :id, :name, {:include_blank => true}, {:id => 'listed_item_content_id'}) +
          listed_item_form.hidden_field(:content_type, :id => 'listed_item_content_type') +
          tag.br +
          '<iframe width="280" height="160" src="https://www.youtube.com/embed/rqnN_VOo_8I" frameborder="0" allowfullscreen></iframe>'.html_safe
          # +
          # link_to('Put a paragraph in the list', paragraphs_for_listed_items_path, :remote => true)
        end
      end +
      div_for(listed_item, :privacy_options_for) do
        if current_magician
          tag.privacy do
            listed_item_form.radio_button(:privacy, :draft, :id => 'listed_item_privacy_draft') +
            listed_item_form.label(:privacy_draft, 'Draft')
          end +
          tag.privacy do
            listed_item_form.radio_button(:privacy, :unreviewed, :id => 'listed_item_privacy_unreviewed') +
            listed_item_form.label(:privacy_unreviewed, 'Public')
          end +
          tag.privacy do
            listed_item_form.radio_button(:privacy, :unreviewed_secret, :id => 'listed_item_privacy_unreviewed_secret') +
            listed_item_form.label(:privacy_unreviewed_secret, 'Just for my muggles')
          end
        else
          listed_item_form.hidden_field :privacy, :value => 'suggested'
        end
      end +
      div_for(listed_item, :submission_of) do
        if current_magician
          listed_item_form.submit '~>ready to add this<~'
        else
          listed_item_form.submit '~>ready to suggest this<~'
        end
      end +
      tag.div(:class => 'instructions center') do
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
        case listed_item.content
        when List
          display_list listed_item.content
        when Paragraph
          paragraph_display listed_item.content
        end
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
        link_to('remove', listed_item_path(listed_item, :listed_item => {:privacy => :removed}, :format => :js), :method => :put, :remote => true) +
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
  
  def listed_item_accepter listed_item
    div_for listed_item, :accepter_for do
      link_to('approve for public', listed_item_path(listed_item, :listed_item => {:privacy => :unreviewed}), :method => :put, :remote => true, :class => 'suggestion_approval accept') +
      link_to('approve for my muggles', listed_item_path(listed_item, :listed_item => {:privacy => :unreviewed_private}), :method => :put, :remote => true, :class => 'suggestion_approval accept_secret') +
      link_to('reject', listed_item_path(listed_item, :listed_item => {:privacy => :rejected}), :method => :put, :remote => true, :class => 'suggestion_approval reject') +
      listed_item_display(listed_item)
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
  
  def paragraph_picker paragraphs
    select_tag 'listed_item[content_id]', options_from_collection_for_select(paragraphs, :id, :lead), :include_blank => true
  end
end
