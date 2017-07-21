module BooksHelper
  def book_title_link book
    if current_magician
      link_to book.title, book
    elsif current_muggle
      link_to book.title, book
    else
      link_to book.title, wwemc_path
    end
  end
  
  def begin_reading_link book
    if current_magician
      link_to 'Read this book online', book, :class => 'begin_reading_link'
    elsif current_muggle
      link_to 'Read this book online', book, :class => 'begin_reading_link'
    else
      link_to 'Read this book online', root_url, :class => 'begin_reading_link', :data => {:confirm => "If you have purchased or received #{book.title}, log in to read it.  Otherwise, you can purchase it for $2!"}
    end
  end
  
  def focus_append_on table_of_contents
    div_for table_of_contents, :focus_tool_for, :class => :focus_tool do
      image_tag asset_path 'write.svg'
    end
  end
end
