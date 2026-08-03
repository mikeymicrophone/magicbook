class CreateFormats < ActiveRecord::Migration[8.1]
  def change
    create_table :formats do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :formats, :code, unique: true
    add_index :formats, :name, unique: true

    create_table :format_sets do |t|
      t.references :format, null: false, foreign_key: true
      t.references :card_set, null: false, foreign_key: true
      t.timestamps
    end

    add_index :format_sets, [:format_id, :card_set_id], unique: true
  end
end
