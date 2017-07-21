module ListsHelper
  def begin_list_link
    if current_magician
      link_to 'Begin new list', new_list_path, :id => 'new_list_link'
    elsif current_muggle
      link_to 'Begin new list', new_list_path, :id => 'new_list_link'
    else
      link_to 'Begin new list', '', :id => 'new_list_link', :data => {:confirm => 'If you have made a purchase, log in.  Otherwise, purchase a $2 book and you will be welcome to make lists!'}
    end
  end
end
