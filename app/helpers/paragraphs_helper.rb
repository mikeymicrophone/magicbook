module ParagraphsHelper
  def paragraph_form table_of_content, paragraph = Paragraph.new
    form_with :model => paragraph, :id => dom_id(table_of_content.section, :append_paragraph_to), :class => 'paragraph_form' do |paragraph_form|
      paragraph_form.text_area(:text) +
      paragraph_form.submit(:Append) +
      hidden_field_tag(:table_of_content_id, nil, :value => table_of_content.id)
    end
  end
  
  def paragraph_control paragraph
    div_with_data_for paragraph do
      mark_up paragraph.text
    end
  end
  
  def paragraph_display paragraph
    div_with_data_for paragraph do
      mark_up paragraph.text
    end
  end
end
