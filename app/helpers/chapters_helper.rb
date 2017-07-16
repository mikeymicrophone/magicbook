module ChaptersHelper
  def chapter_form edition
    form_with :model => edition.chapters.new, :id => dom_id(edition, :append_chapter_to) do |chapter_form|
      chapter_form.text_field(:title, :placeholder => 'Chapter title') +
      tag.br +
      chapter_form.text_area(:subtitle, :placeholder => 'Chapter subtitle') +
      chapter_form.submit(:Append) +
      hidden_field_tag(:edition, :id, :value => edition.id) +
      hidden_field_tag(:book, :id, :value => edition.book.id)
    end
  end
  
  def chapter_control chapter
    div_with_data_for chapter do
      focus_append_on(chapter) +
      tag.header do
        chapter.title
      end +
      chapter.subtitle
    end
  end
end
