class CreateIdentitifiers < ActiveRecord::Migration[5.1]
  def change
    create_table :identitifiers do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.belongs_to :magician
      t.belongs_to :muggle
      
      t.timestamps
    end
  end
end
