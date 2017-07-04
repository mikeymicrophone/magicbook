module ChaptersHelper
  def chapter_form edition
    form_with :model => edition.chapters.new do |chapter_form|
      chapter_form.text_field(:title) +
      chapter_form.text_area(:subtitle) +
      chapter_form.submit(:Append) +
      hidden_field_tag(:edition, :id, :value => edition.id) +
      hidden_field_tag(:book, :id, :value => edition.book.id)
    end
  end
end
