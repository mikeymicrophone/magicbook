class CreatePurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases do |t|
      t.string :email
      t.string :stripe_token

      t.timestamps
    end
  end
end
