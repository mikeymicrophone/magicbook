module SectionsHelper
  def section_form chapter
    form_with :model => chapter.sections.new do |section_form|
      section_form.text_field(:heading) +
      section_form.text_area(:subheading) +
      section_form.submit(:Append) +
      hidden_field_tag(:chapter, :id, :value => chapter.id) +
      hidden_field_tag(:edition, :id, :value => chapter.edition.id) +
      hidden_field_tag(:book, :id, :value => chapter.book.id)
    end
  end
end
