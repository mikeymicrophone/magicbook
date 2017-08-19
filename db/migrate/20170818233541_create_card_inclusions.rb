class CreateCardInclusions < ActiveRecord::Migration[5.1]
  def change
    create_table :card_inclusions do |t|
      t.belongs_to :card, foreign_key: true
      t.string :piece_type
      t.integer :piece_id

      t.timestamps
    end
  end
end
