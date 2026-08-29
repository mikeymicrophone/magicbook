class AddTagContextColors < ActiveRecord::Migration[8.1]
  def change
    add_column :tag_contexts, :color, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE tag_contexts
          SET color = CASE slug
            WHEN 'flags' THEN '#6e5a86'
            WHEN 'format' THEN '#3d6b5a'
            WHEN 'era' THEN '#9a6b2f'
            WHEN 'strategy' THEN '#8a4a32'
            WHEN 'power-level' THEN '#4a628a'
            ELSE '#c9b896'
          END
        SQL
      end
    end

    change_column_null :tag_contexts, :color, false

    create_table :tag_context_color_overrides do |t|
      t.references :mage, null: false, foreign_key: true, index: false
      t.references :tag_context, null: false, foreign_key: true
      t.string :color, null: false
      t.timestamps
    end

    add_index :tag_context_color_overrides, [:mage_id, :tag_context_id],
      unique: true,
      name: "index_tag_context_color_overrides_on_mage_and_context"
  end
end
