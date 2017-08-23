class ListedItemHasReplacing < ActiveRecord::Migration[5.1]
  def change
    add_column :listed_items, :replacing, :integer
  end
end
