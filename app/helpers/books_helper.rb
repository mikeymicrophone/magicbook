module BooksHelper
  def focus_append_on table_of_contents
    div_for table_of_contents, :focus_tool_for, :class => :focus_tool do
      image_tag asset_path 'write.svg'
    end
  end
end
