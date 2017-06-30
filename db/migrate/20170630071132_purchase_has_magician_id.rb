class PurchaseHasMagicianId < ActiveRecord::Migration[5.1]
  def change
    add_column :purchases, :magician_id, :bigint
  end
end
