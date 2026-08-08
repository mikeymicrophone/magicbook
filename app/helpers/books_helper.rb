module BooksHelper
  def book_title_link book
    if current_mage
      link_to book.title, book
    else
      link_to book.title, wwemc_path, :class => 'purchase_trigger'
    end
  end
  
  def begin_reading_link book
    if current_mage&.admin?
      link_to('Read this book online', book, :class => 'begin_reading_link') +
      tag.br +
      link_to('Edit this book', edit_book_path(book), :class => 'begin_reading_link')
    elsif current_mage
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
    case table_of_content.content
    when Section
      paragraph_append_control(table_of_content)
    when Paragraph
      citation_append_control(table_of_content)
    else
      content_type = table_of_content.content.class.name.underscore
      appended_content_type = { 'edition' => 'chapter', 'chapter' => 'section' }.fetch(content_type, content_type)
      frame_id = dom_id(table_of_content, "append_#{appended_content_type}_form")

      turbo_frame_tag frame_id do
        link_to send("append_#{content_type}_path", table_of_content.content, table_of_content_id: table_of_content.id), title: "Add #{content_type}", aria: { label: "Add #{content_type}" }, data: { turbo_frame: frame_id } do
          div_for table_of_content, :focus_tool_for, :class => :new_focus_tool do
            image_tag asset_path('write.svg'), :title => "Add to #{content_type}"
          end
        end
      end
    end
  end
end
