module ListsHelper
  def display_list list
    div_for list do
      div_for(list, :name_of) do
        list.name
      end +
      if list.description?
        div_for list, :description_of do
          mark_up list.description
        end
      else
        ''.html_safe
      end +
      div_for(list, :listed_items_in) do
        visible_items_for(list).map do |listed_item|
          listed_item_display listed_item
        end.join.html_safe
      end
    end
  end
  
  def begin_list_link
    if current_magician
      link_to 'Begin new list', new_list_path, :id => 'new_list_link'
    elsif current_muggle
      link_to 'Begin new list', new_list_path, :id => 'new_list_link'
    else
      link_to 'Begin new list', '', :id => 'new_list_link', :data => {:confirm => 'If you have made a purchase, log in.  Otherwise, purchase a $2 book and you will be welcome to make lists!'}
    end
  end
  
  def publish_controls_for list
    if list.magician == current_magician
      if list.privacy == 'draft'
        tag.div :class => 'right' do
          link_to('publish', list_path(list, :list => {:privacy => 'unreviewed'}), :method => :put) +
          link_to('[for my muggles]', list_path(list, :list => {:privacy => 'unreviewed_secret'}), :method => :put)
        end
      end
    end
  end
end
