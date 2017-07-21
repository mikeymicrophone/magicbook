class ListedItemsHavePrivacy < ActiveRecord::Migration[5.1]
  def change
    add_column :listed_items, :privacy, :integer
  end
end
