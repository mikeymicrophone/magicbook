class ListsCanBePinned < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :pin, :integer
  end
end
