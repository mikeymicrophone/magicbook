class CreateCitations < ActiveRecord::Migration[5.1]
  def change
    create_table :citations do |t|
      t.belongs_to :paragraph, foreign_key: true
      t.text :source
      t.text :finding

      t.timestamps
    end
  end
end
