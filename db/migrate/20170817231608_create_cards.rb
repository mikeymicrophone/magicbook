class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.integer :types
      t.integer :colors
      t.integer :converted_mana_cost
      t.integer :multiverse_id
      t.string :image_url

      t.timestamps
    end
  end
end
