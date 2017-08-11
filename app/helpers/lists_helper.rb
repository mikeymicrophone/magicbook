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
  
  def submission_reviewer_for list
    if list.magician == current_magician
      if list.listed_items.suggested.present?
        div_for list, :submission_reviewer_for do 
          list.listed_items.suggested.map do |listed_item|
            listed_item_accepter listed_item
          end.join.html_safe
        end
      end
    end
  end
  
  def open_graph_tags_for list
    tag.div :class => 'open_graph_tags' do
      tag.meta(:property => 'og:url', :content => list_url(list)) +
      tag.meta(:property => 'og:type', :content => 'article') +
      tag.meta(:property => 'og:title', :content => list.name) +
      tag.meta(:property => 'og:description', :content => list.description) +
      tag.meta(:property => 'og:image', :content => asset_path('ways we mage logo vertical.png')) +
      tag.meta(:property => 'fb:app_id', :content => ENV['FACEBOOK_APP_ID'])
    end
  end
end
