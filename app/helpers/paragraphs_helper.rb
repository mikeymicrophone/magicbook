module ParagraphsHelper
  def paragraph_form section
    form_with :model => section.paragraphs.new, :id => dom_id(section, :append_paragraph_to) do |paragraph_form|
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
      focus_append_on(paragraph) +
      paragraph.text
    end
  end
end
