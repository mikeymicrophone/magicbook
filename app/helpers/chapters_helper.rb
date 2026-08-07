module ChaptersHelper
  def chapter_form table_of_content, chapter = Chapter.new
    frame_id = chapter.persisted? ? dom_id(chapter) : dom_id(table_of_content, :append_chapter_form)

    turbo_frame_tag frame_id, data: { controller: 'toc-editor' } do
      form_with model: chapter, local: true, class: 'chapter_form', data: { turbo_stream: true } do |chapter_form|
        safe_join([
          chapter_form.text_field(:title, placeholder: 'Chapter title', class: 'chapter_title', data: { toc_editor_target: 'input' }),
          tag.br,
          chapter_form.text_area(:subtitle, placeholder: 'Chapter subtitle', class: 'chapter_subtitle'),
          chapter_form.submit(chapter.persisted? ? 'Save' : 'Append'),
          hidden_field_tag(:table_of_content_id, table_of_content.id)
        ])
      end
    end
  end
  
  def chapter_control chapter_table_of_content
    chapter = chapter_table_of_content.chapter
    div_for(chapter, :data_on) do
      tag.header(:class => 'chapter_title') do
        chapter.title
      end +
      div_for(chapter, :subtitle_of) do
        tag.header :class => 'chapter_subtitle' do
          chapter.subtitle
        end
      end
    end +
    edit_controls_for_chapter(chapter_table_of_content)
  end
  
  def edit_controls_for_chapter chapter_table_of_content
    chapter = chapter_table_of_content.chapter
    div_for(chapter, :controls_for, :class => 'controls') do
      if chapter_table_of_content.previous.present?
        link_to('promote', promote_chapter_path(chapter, :table_of_content_id => chapter_table_of_content), title: "put before previous chapter (at #{chapter_table_of_content.ordering})", data: { turbo_method: :put, turbo_stream: true })
      end.to_s.html_safe +
      link_to('edit', edit_chapter_path(chapter, :table_of_content_id => chapter_table_of_content), data: { action: 'click->toc-editor#open', turbo_frame: dom_id(chapter) }) +
      link_to('remove', chapter_path(chapter, :table_of_content_id => chapter_table_of_content), data: { turbo_method: :delete, turbo_stream: true })
    end
  end
end
