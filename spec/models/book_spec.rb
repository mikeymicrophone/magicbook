require 'rails_helper'

RSpec.describe Book, :type => :model do
  describe 'version reporting' do
    before do
      @book = Fabricate :book
    end
    
    it 'should know its major version' do
      expect(@book.major_version).to be_a Fixnum
    end
    
    it 'should know its minor version' do
      expect(@book.minor_version).to be_a Fixnum
    end
    
    it 'should know its patch version' do
      expect(@book.patch_version).to be_a Fixnum
    end
  end
end
