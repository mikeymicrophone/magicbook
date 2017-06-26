class CreateEditions < ActiveRecord::Migration[5.1]
  def change
    create_table :editions do |t|
      t.belongs_to :book, foreign_key: true
      t.integer :major
      t.integer :minor
      t.integer :patch
      t.text :note
      t.datetime :release
      t.string :pdf

      t.timestamps
    end
  end
end
