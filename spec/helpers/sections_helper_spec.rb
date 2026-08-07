require 'rails_helper'

RSpec.describe SectionsHelper, type: :helper do
  it 'uses a Turbo Frame and Stream submission for a new section form' do
    chapter = Chapter.new(id: 9)
    table_of_content = TableOfContent.new(id: 14, chapter: chapter)

    html = helper.section_form(table_of_content)

    expect(html).to include('turbo-frame')
    expect(html).to include('data-turbo-stream="true"')
    expect(html).not_to include('data-remote="true"')
  end
end
