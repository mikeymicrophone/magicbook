class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.integer :ordering
      t.string :heading
      t.text :subheading

      t.timestamps
    end
  end
end
