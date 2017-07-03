module ParagraphsHelper
  def paragraph_form  section
    form_with :model => section.paragraphs.new do |paragraph_form|
      paragraph_form.text_area(:text) +
      paragraph_form.submit(:Append) +
      paragraph_form.hidden_field(:section_id) +
      paragraph_form.hidden_field(:ordering)
    end
  end
end
