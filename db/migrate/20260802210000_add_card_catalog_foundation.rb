class AddCardCatalogFoundation < ActiveRecord::Migration[8.1]
  def up
    create_table :card_concepts do |t|
      t.string :name, null: false
      t.string :oracle_id
      t.timestamps
    end
    add_index :card_concepts, :name, unique: true
    add_index :card_concepts, :oracle_id, unique: true, where: "oracle_id IS NOT NULL"

    create_table :card_sets do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.date :released_on
      t.string :set_type
      t.timestamps
    end
    add_index :card_sets, :code, unique: true

    add_reference :cards, :card_concept, foreign_key: true
    add_reference :cards, :card_set, foreign_key: true
    add_column :cards, :scryfall_id, :string
    add_column :cards, :collector_number, :string
    add_column :cards, :released_on, :date
    add_column :cards, :preferred, :boolean, default: false, null: false
    add_index :cards, :scryfall_id, unique: true, where: "scryfall_id IS NOT NULL"
    add_index :cards, [:card_concept_id, :card_set_id], unique: true,
      where: "card_set_id IS NOT NULL", name: "index_cards_on_concept_and_set"
    add_index :cards, :card_concept_id, unique: true,
      where: "preferred", name: "index_cards_on_preferred_concept"

    execute <<~SQL.squish
      INSERT INTO card_concepts (name, created_at, updated_at)
      SELECT DISTINCT name, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM cards
      ON CONFLICT (name) DO NOTHING
    SQL
    execute <<~SQL.squish
      UPDATE cards
      SET card_concept_id = card_concepts.id
      FROM card_concepts
      WHERE cards.name = card_concepts.name
    SQL
    change_column_null :cards, :card_concept_id, false

    create_table :card_functions do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.timestamps
    end
    add_index :card_functions, :name, unique: true
    add_index :card_functions, :slug, unique: true

    create_table :card_function_relations do |t|
      t.references :parent_function, null: false, foreign_key: { to_table: :card_functions }
      t.references :child_function, null: false, foreign_key: { to_table: :card_functions }
      t.timestamps
    end
    add_index :card_function_relations, [:parent_function_id, :child_function_id],
      unique: true, name: "index_card_function_relations_on_parent_and_child"

    create_table :card_function_assignments do |t|
      t.references :card_concept, null: false, foreign_key: true
      t.references :card_function, null: false, foreign_key: true
      t.timestamps
    end
    add_index :card_function_assignments, [:card_concept_id, :card_function_id],
      unique: true, name: "index_card_function_assignments_on_concept_and_function"
  end

  def down
    remove_reference :cards, :card_concept, foreign_key: true
    remove_reference :cards, :card_set, foreign_key: true
    remove_column :cards, :scryfall_id
    remove_column :cards, :collector_number
    remove_column :cards, :released_on
    remove_column :cards, :preferred
    drop_table :card_function_assignments
    drop_table :card_function_relations
    drop_table :card_functions
    drop_table :card_sets
    drop_table :card_concepts
  end
end
