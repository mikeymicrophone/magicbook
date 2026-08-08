class AddPasswordlessAuthenticationToMages < ActiveRecord::Migration[8.1]
  def change
    add_column :mages, :magic_link_token_digest, :string
    add_column :mages, :magic_link_sent_at, :datetime
    add_column :mages, :webauthn_user_handle, :string

    add_index :mages, :magic_link_token_digest, unique: true
    add_index :mages, :webauthn_user_handle, unique: true
    add_index :identifiers, [:provider, :uid], unique: true

    create_table :passkeys do |t|
      t.references :mage, null: false, foreign_key: true
      t.string :external_id, null: false
      t.text :public_key, null: false
      t.bigint :sign_count, null: false, default: 0
      t.string :transports, array: true, null: false, default: []
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :passkeys, :external_id, unique: true
  end
end
