class PurchaseHasToken < ActiveRecord::Migration[5.1]
  def change
    add_column :purchases, :token, :string
  end
end
