require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe '#price' do
    it 'sums the stored prices of its books' do
      purchase = Fabricate.build(:purchase)
      purchase.books << Fabricate(:book, price_cents: 500)
      purchase.books << Fabricate(:book, price_cents: 1250)

      expect(purchase.price).to eq(1750)
    end
  end

  describe '#default_book' do
    it 'uses the selected book when a checkout form supplies one' do
      selected_book = Fabricate(:book, price_cents: 750)
      purchase = Fabricate.build(:purchase, book_id: selected_book.id)

      purchase.send(:default_book)

      expect(purchase.books).to contain_exactly(selected_book)
    end
  end
end
