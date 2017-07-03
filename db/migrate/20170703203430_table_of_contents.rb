class TableOfContents < ActiveRecord::Migration[5.1]
  def change
    create_table :table_of_contents do |t|
      t.belongs_to :book, :foreign_key => true
      t.belongs_to :edition, :foreign_key => true
      t.belongs_to :chapter, :foreign_key => true
      t.belongs_to :section, :foreign_key => true
      t.belongs_to :paragraph, :foreign_key => true
      t.belongs_to :citation, :foreign_key => true
      t.integer :ordering
      t.integer :flags, :null => false, :default => 0
      t.timestamps
    end
  end
end
