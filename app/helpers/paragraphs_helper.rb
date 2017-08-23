module ParagraphsHelper
  def paragraph_form table_of_content, paragraph = Paragraph.new
    form_with :model => paragraph, :id => dom_id(table_of_content.section, :append_paragraph_to), :class => 'paragraph_form' do |paragraph_form|
      paragraph_form.text_area(:text) +
      paragraph_form.submit(:Append) +
      hidden_field_tag(:table_of_content_id, nil, :value => table_of_content.id)
    end
  end
  
  def paragraph_control paragraph_table_of_content
    paragraph = paragraph_table_of_content.paragraph
    div_with_data_for paragraph do
      mark_up paragraph.text +
      edit_controls_for_paragraph(paragraph_table_of_content)
    end
  end
  
  def edit_controls_for_paragraph paragraph_table_of_content
    paragraph = paragraph_table_of_content.paragraph
    section_table_of_content = paragraph_table_of_content.parent
    div_for(paragraph, :controls_for, :class => 'controls') do
      focus_append_on(paragraph) +
      if section_table_of_content.succeeding.present?
        link_to('delay', delay_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), :method => :put, :remote => true, :title => 'move to next section')
      end.to_s.html_safe +
      if paragraph_table_of_content.previous.present?
        link_to('promote', promote_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), :method => :put, :remote => true, :title => "put before previous paragraph (at #{paragraph_table_of_content.ordering})")
      end.to_s.html_safe +
      link_to('edit', edit_paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), :remote => true) +
      link_to('remove', paragraph_path(paragraph, :table_of_content_id => paragraph_table_of_content), :method => :delete, :remote => true)
    end
  end
  
  def paragraph_display paragraph
    div_with_data_for paragraph do
      mark_up paragraph.text
    end
  end
end
