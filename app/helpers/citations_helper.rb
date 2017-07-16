module CitationsHelper
  def citation_form paragraph
    form_with :model => paragraph.citations.new, :id => dom_id(paragraph, :append_citation_to) do |citation_form|
      citation_form.text_area(:finding, :placeholder => 'finding') +
      tag.br +
      citation_form.text_field(:source, :placeholder => 'source') +
      citation_form.submit(:Append) +
      hidden_field_tag(:paragraph, :id, :value => paragraph.id) +
      hidden_field_tag(:section, :id, :value => paragraph.section.id) +
      hidden_field_tag(:chapter, :id, :value => paragraph.chapter.id) +
      hidden_field_tag(:edition, :id, :value => paragraph.edition.id) +
      hidden_field_tag(:book, :id, :value => paragraph.book.id)
    end
  end
  
  def citation_control citation
    div_with_data_for citation do
      citation.finding +
      citation.source
    end
  end
end
