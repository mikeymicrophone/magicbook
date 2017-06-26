class CreatePurchasedBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :purchased_books do |t|
      t.belongs_to :book, foreign_key: true
      t.belongs_to :purchase, foreign_key: true

      t.timestamps
    end
  end
end
