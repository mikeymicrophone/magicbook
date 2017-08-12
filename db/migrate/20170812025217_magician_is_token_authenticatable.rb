class MagicianIsTokenAuthenticatable < ActiveRecord::Migration[5.1]
  def change
    add_column :magicians, :authentication_token, :string
    add_column :magicians, :authentication_token_created_at, :datetime
  end
end
