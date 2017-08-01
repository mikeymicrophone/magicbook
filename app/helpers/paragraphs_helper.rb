module ParagraphsHelper
  def paragraph_form section, paragraph = section.paragraphs.new
    form_with :model => paragraph, :id => dom_id(section, :append_paragraph_to), :class => 'paragraph_form' do |paragraph_form|
      paragraph_form.text_area(:text) +
      paragraph_form.submit(:Append) +
      hidden_field_tag(:section, :id, :value => section.id) +
      hidden_field_tag(:chapter, :id, :value => section.chapter.id) +
      hidden_field_tag(:edition, :id, :value => section.edition.id) +
      hidden_field_tag(:book, :id, :value => section.book.id)
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
