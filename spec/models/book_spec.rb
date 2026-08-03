require 'rails_helper'

RSpec.describe Book, :type => :model do
  describe 'version reporting' do
    before do
      @book = Fabricate :book
    end
    
    it 'should know its major version' do
      expect(@book.major_version).to be_an Integer
    end
    
    it 'should know its minor version' do
      expect(@book.minor_version).to be_an Integer
    end
    
    it 'should know its patch version' do
      expect(@book.patch_version).to be_an Integer
    end
  end

  describe 'pricing' do
    it 'formats a stored price in cents for display' do
      book = Fabricate(:book, price_cents: 1250)

      expect(book.formatted_price).to eq('$12.50')
    end

    it 'does not allow a negative price' do
      book = Fabricate.build(:book, price_cents: -1)

      expect(book).not_to be_valid
    end
  end
end
