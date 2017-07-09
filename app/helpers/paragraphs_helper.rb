module ParagraphsHelper
  def paragraph_form section
    form_with :model => section.paragraphs.new do |paragraph_form|
      paragraph_form.text_area(:text) +
      paragraph_form.submit(:Append) +
      hidden_field_tag(:section, :id, :value => section.id) +
      hidden_field_tag(:chapter, :id, :value => section.chapter.id) +
      hidden_field_tag(:edition, :id, :value => section.edition.id) +
      hidden_field_tag(:book, :id, :value => section.book.id)
    end
  end
end
