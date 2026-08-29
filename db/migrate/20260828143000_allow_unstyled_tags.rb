class AllowUnstyledTags < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tags, :tag_context_id, true
    remove_index :tags, name: "index_tags_on_tag_context_id_and_slug"
    add_index :tags, [:tag_context_id, :slug],
      unique: true,
      where: "tag_context_id IS NOT NULL",
      name: "index_tags_on_tag_context_id_and_slug"
    add_index :tags, :slug,
      unique: true,
      where: "tag_context_id IS NULL",
      name: "index_tags_on_unstyled_slug"
  end
end
