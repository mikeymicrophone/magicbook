class CreateMagesAndInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :mages do |t|
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.string :first_name
      t.string :last_name
      t.string :authentication_token
      t.datetime :authentication_token_created_at
      t.boolean :admin, null: false, default: false
      t.boolean :must_set_password, null: false, default: false
      t.timestamps
    end

    add_index :mages, :email, unique: true
    add_index :mages, :reset_password_token, unique: true
    add_index :mages, :confirmation_token, unique: true
    add_index :mages, :authentication_token, unique: true

    add_reference :purchases, :mage, foreign_key: true
    add_reference :lists, :mage, foreign_key: true
    add_reference :identifiers, :mage, foreign_key: true

    create_table :invitations do |t|
      t.references :purchase, null: false, foreign_key: true
      t.references :mage, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :mages }
      t.timestamps
    end

    add_index :invitations, [:purchase_id, :mage_id], unique: true
  end
end
