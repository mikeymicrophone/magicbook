class AddCategoryToCardSets < ActiveRecord::Migration[8.1]
  def up
    add_column :card_sets, :category, :integer, null: false, default: 6
    add_index :card_sets, :category

    execute <<~SQL.squish
      UPDATE card_sets
      SET category = CASE set_type
        WHEN 'core' THEN 0
        WHEN 'expansion' THEN 0
        WHEN 'starter' THEN 0
        WHEN 'commander' THEN 1
        WHEN 'duel_deck' THEN 1
        WHEN 'draft_innovation' THEN 1
        WHEN 'planechase' THEN 1
        WHEN 'archenemy' THEN 1
        WHEN 'arsenal' THEN 1
        WHEN 'premium_deck' THEN 1
        WHEN 'spellbook' THEN 1
        WHEN 'masters' THEN 2
        WHEN 'masterpiece' THEN 2
        WHEN 'from_the_vault' THEN 2
        WHEN 'eternal' THEN 2
        WHEN 'promo' THEN 3
        WHEN 'token' THEN 4
        WHEN 'funny' THEN 5
        WHEN 'minigame' THEN 5
        WHEN 'vanguard' THEN 5
        ELSE 6
      END
    SQL
  end

  def down
    remove_index :card_sets, :category
    remove_column :card_sets, :category
  end
end
