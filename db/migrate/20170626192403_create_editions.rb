class CreateEditions < ActiveRecord::Migration[5.1]
  def change
    create_table :editions do |t|
      t.belongs_to :book, foreign_key: true
      t.string :version
      t.text :note
      t.datetime :release
      t.string :pdf

      t.timestamps
    end
  end
end
