module ChaptersHelper
  def chapter_form table_of_content, chapter = Chapter.new
    form_with :model => chapter, :id => dom_id(table_of_content.edition, :append_chapter_to) do |chapter_form|
      chapter_form.text_field(:title, :placeholder => 'Chapter title') +
      tag.br +
      chapter_form.text_area(:subtitle, :placeholder => 'Chapter subtitle') +
      chapter_form.submit(:Append) +
      hidden_field_tag(:table_of_content_id, nil, :value => table_of_content.id)
    end
  end
  
  def chapter_control chapter_table_of_content
    chapter = chapter_table_of_content.chapter
    div_for(chapter, :data_on) do
      tag.header(:class => 'chapter_title') do
        chapter.title
      end +
      div_for(@chapter, :subtitle_of) do
        tag.header :class => 'chapter_subtitle' do
          chapter.subtitle
        end
      end
    end +
    edit_controls_for_chapter(chapter_table_of_content)
  end
  
  def edit_controls_for_chapter chapter_table_of_content
    chapter = chapter_table_of_content.chapter
    edition_table_of_content = chapter_table_of_content.parent
    div_for(chapter, :controls_for, :class => 'controls') do
      if chapter_table_of_content.previous.present?
        link_to('promote', promote_chapter_path(chapter, :table_of_content_id => chapter_table_of_content), :method => :put, :remote => true, :title => "put before previous chapter (at #{chapter_table_of_content.ordering})")
      end.to_s.html_safe +
      link_to('edit', edit_chapter_path(chapter, :table_of_content_id => chapter_table_of_content), :remote => true) +
      link_to('remove', chapter_path(chapter, :table_of_content_id => chapter_table_of_content), :method => :delete, :remote => true)
    end
  end
end
