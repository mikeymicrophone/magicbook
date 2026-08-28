class CreateTagging < ActiveRecord::Migration[8.1]
  def change
    create_table :tag_contexts do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :kind, null: false, default: "user"
      t.timestamps

      t.index :slug, unique: true
    end

    create_table :tags do |t|
      t.references :tag_context, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :name, null: false
      t.string :kind, null: false, default: "user"
      t.timestamps

      t.index [:tag_context_id, :slug], unique: true
    end

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, null: false, polymorphic: true
      t.references :mage, null: true, foreign_key: true
      t.timestamps

      t.index [:tag_id, :taggable_type, :taggable_id], unique: true
    end
  end
end
