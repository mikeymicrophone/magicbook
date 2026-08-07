require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ChaptersHelper. For example:
#
# describe ChaptersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ChaptersHelper, type: :helper do
  it 'uses a Turbo Frame and Stream submission for a new chapter form' do
    edition = Edition.new(id: 7)
    table_of_content = TableOfContent.new(id: 12, edition: edition)

    html = helper.chapter_form(table_of_content)

    expect(html).to include('turbo-frame')
    expect(html).to include('data-turbo-stream="true"')
    expect(html).not_to include('data-remote="true"')
  end
end
