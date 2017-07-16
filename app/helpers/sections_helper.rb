module SectionsHelper
  def section_form chapter
    form_with :model => chapter.sections.new, :id => dom_id(chapter, :append_section_to) do |section_form|
      section_form.text_field(:heading, :placeholder => 'Section heading') +
      tag.br +
      section_form.text_area(:subheading, :placeholder => 'Section subheading') +
      section_form.submit(:Append) +
      hidden_field_tag(:chapter, :id, :value => chapter.id) +
      hidden_field_tag(:edition, :id, :value => chapter.edition.id) +
      hidden_field_tag(:book, :id, :value => chapter.book.id)
    end
  end
  
  def section_control section
    div_with_data_for section do
      focus_append_on(section) +
      tag.header do
        section.heading
      end +
      section.subheading
    end
  end
end
