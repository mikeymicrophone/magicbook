module BooksHelper
  def book_title_link book
    if current_magician
      link_to book.title, book
    elsif current_muggle
      link_to book.title, book
    else
      link_to book.title, wwemc_path, :class => 'purchase_trigger'
    end
  end
  
  def begin_reading_link book
    if current_scribe
      link_to('Read this book online', book, :class => 'begin_reading_link') +
      tag.br +
      link_to('Edit this book', edit_book_path(book), :class => 'begin_reading_link')
    elsif current_magician
      link_to 'Read this book online', book, :class => 'begin_reading_link'
    elsif current_muggle
      link_to 'Read this book online', book, :class => 'begin_reading_link'
    else
      link_to 'Read this book online', root_url, :class => 'begin_reading_link purchase_trigger', :data => {:confirm => "If you have purchased or received #{book.title}, log in to read it.  Otherwise, you can purchase it for $2!"}
    end
  end
  
  def focus_append_on table_of_contents
    div_for table_of_contents, :focus_tool_for, :class => :focus_tool do
      image_tag asset_path('write.svg'), :title => "Add to #{table_of_contents.class.name.underscore}"
    end
  end
  
  def append_to table_of_content
    link_to send("append_#{table_of_content.content.class.name.underscore}_path", table_of_content.content, :table_of_content_id => table_of_content.id), :remote => true do
      div_for table_of_content, :focus_tool_for, :class => :new_focus_tool do
        image_tag asset_path('write.svg'), :title => "Add to #{table_of_content.content.class.name.underscore}"
      end
    end
  end
end
