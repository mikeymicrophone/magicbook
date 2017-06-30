class CreateChapters < ActiveRecord::Migration[5.1]
  def change
    create_table :chapters do |t|
      t.belongs_to :edition, foreign_key: true
      t.integer :ordering
      t.string :title
      t.text :subtitle

      t.timestamps
    end
  end
end
