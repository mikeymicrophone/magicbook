class AddLegalityWindowToFormatSets < ActiveRecord::Migration[8.1]
  def change
    add_column :format_sets, :legal_from, :date
    add_column :format_sets, :legal_until, :date
  end
end
