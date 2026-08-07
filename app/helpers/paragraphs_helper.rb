module ParagraphsHelper
  def paragraph_form(table_of_content, paragraph = Paragraph.new, frame_id: nil)
    frame_id ||= paragraph.persisted? ? dom_id(paragraph) : dom_id(table_of_content, :append_paragraph_form)

    turbo_frame_tag frame_id, data: { controller: 'toc-editor' } do
      form_with model: paragraph, local: true, class: 'paragraph_form', data: { turbo_stream: true } do |paragraph_form|
        safe_join([
          paragraph_form.text_area(:text, data: { toc_editor_target: 'input' }),
          paragraph_form.submit(paragraph.persisted? ? 'Save' : 'Append'),
          hidden_field_tag(:table_of_content_id, table_of_content.id)
        ])
      end
    end
  end
  
  def paragraph_control(paragraph_table_of_content)
    paragraph = paragraph_table_of_content.paragraph

    turbo_frame_tag dom_id(paragraph), data: { controller: 'toc-editor' } do
      content_tag(:div, class: 'div_with_data paragraph', data: { paragraph_id: paragraph.id }) do
        safe_join([
          mark_up(paragraph.text),
          content_tag(:div, id: dom_id(paragraph, :citations)) do
            safe_join(paragraph_table_of_content.children.ordered.map { |citation_table_of_content| citation_control(citation_table_of_content) })
          end,
          edit_controls_for_paragraph(paragraph_table_of_content)
        ])
      end
    end
  end

  def paragraph_append_control(section_table_of_content)
    frame_id = dom_id(section_table_of_content, :append_paragraph_form)

    turbo_frame_tag frame_id do
      link_to append_section_path(section_table_of_content.section, table_of_content_id: section_table_of_content.id), title: 'Add paragraph', aria: { label: 'Add paragraph' }, data: { turbo_frame: frame_id } do
        div_for section_table_of_content, :focus_tool_for, class: :new_focus_tool do
          image_tag asset_path('write.svg'), title: 'Add paragraph'
        end
      end
    end
  end
  
  def edit_controls_for_paragraph paragraph_table_of_content
    paragraph = paragraph_table_of_content.paragraph
    section_table_of_content = paragraph_table_of_content.parent
    div_for(paragraph, :controls_for, :class => 'controls editor_controls paragraph_controls') do
      append_to(paragraph_table_of_content) +
      if section_table_of_content.succeeding.present?
        link_to('↓', delay_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), class: 'editor_icon_link', :method => :put, :remote => true, :title => 'Move to next section', aria: { label: 'Move to next section' }, data: { turbo: false })
      end.to_s.html_safe +
      if paragraph_table_of_content.previous.present?
        link_to('↑', promote_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), class: 'editor_icon_link', :method => :put, :remote => true, :title => 'Move paragraph up', aria: { label: 'Move paragraph up' }, data: { turbo: false })
      end.to_s.html_safe +
      link_to(edit_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), class: 'editor_icon_link paragraph_edit_link', title: 'Edit paragraph', aria: { label: 'Edit paragraph' }, data: { action: 'click->toc-editor#open', turbo_frame: dom_id(paragraph) }) do
        image_tag(asset_path('write.svg'), alt: '')
      end +
      link_to('×', paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), class: 'editor_icon_link paragraph_remove_link', title: 'Remove paragraph', aria: { label: 'Remove paragraph' }, data: { turbo_method: :delete, turbo_stream: true })
    end
  end
  
  def paragraph_display paragraph
    div_with_data_for paragraph do
      mark_up paragraph.text
    end
  end
end
