class AddPriceCentsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :price_cents, :integer, null: false, default: 500
  end
end
