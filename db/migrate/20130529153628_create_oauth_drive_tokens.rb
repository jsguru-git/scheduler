class CreateOauthDriveTokens < ActiveRecord::Migration
  def change
    
    create_table :oauth_drive_tokens do |t|
      t.integer :user_id, :provider_number
      t.string :access_token, :refresh_token, :client_number
      t.datetime :expires_at
      t.timestamps
    end
    
    add_index :oauth_drive_tokens, [:user_id]
  end
end
