class CreateLists < ActiveRecord::Migration[5.1]
  def change
    create_table :lists do |t|
      t.string :name
      t.text :description
      t.belongs_to :magician
      t.integer :mode
      t.integer :privacy
      t.timestamps
    end
    
    create_table :listed_items do |t|
      t.belongs_to :list
      t.text :designation
      t.text :expression
      t.string :content_type
      t.integer :content_id
      t.integer :ordering
      t.timestamps
    end
  end
end
