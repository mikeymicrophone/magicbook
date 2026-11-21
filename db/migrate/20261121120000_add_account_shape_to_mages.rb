class AddAccountShapeToMages < ActiveRecord::Migration[8.1]
  def change
    add_column :mages, :username, :string
    add_column :mages, :display_name, :string
    add_index :mages, 'lower(username)', unique: true, where: 'username IS NOT NULL', name: 'index_mages_on_lower_username'
  end
end
