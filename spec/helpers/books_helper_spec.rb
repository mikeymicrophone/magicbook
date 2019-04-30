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
RSpec.describe BooksHelper, type: :helper do
  context 'magician is logged in' do
    before do
      @book = Fabricate :book
      sign_in Fabricate :magician
    end
    
    it 'should link book title to book show page' do
      expect(helper.book_title_link(@book)).to include @book.title
      expect(helper.book_title_link(@book)).to include book_path(@book)
    end
  end
  
  context 'muggle is logged in' do
    
  end
  
  context 'guest is not logged in' do
    
  end
end
