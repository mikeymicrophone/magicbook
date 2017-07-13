class CreateMuggles < ActiveRecord::Migration[5.1]
  def change
    create_table :muggles do |t|
      t.string :email, :required => true
      t.belongs_to :magician
      t.belongs_to :purchase
      
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.index ["confirmation_token"], name: "index_muggles_on_confirmation_token", unique: true
      t.index ["email"], name: "index_muggles_on_email", unique: true
      t.index ["reset_password_token"], name: "index_muggles_on_reset_password_token", unique: true

      t.timestamps
    end
  end
end
