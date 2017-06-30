class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.belongs_to :chapter, foreign_key: true
      t.integer :ordering
      t.string :heading
      t.text :subheading

      t.timestamps
    end
  end
end
