class CreateParagraphs < ActiveRecord::Migration[5.1]
  def change
    create_table :paragraphs do |t|
      t.integer :ordering
      t.text :text

      t.timestamps
    end
  end
end
