class AddOracleDataToCardConcepts < ActiveRecord::Migration[8.1]
  def change
    add_column :card_concepts, :oracle_text, :text, null: false, default: ""
    add_column :card_concepts, :keywords, :string, array: true, null: false, default: []
    add_column :card_function_assignments, :source, :string, null: false, default: "manual"
    add_index :card_function_assignments, :source
  end
end
