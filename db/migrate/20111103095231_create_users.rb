class CreateUsers < ActiveRecord::Migration
    def change
        create_table :users do |t|
            t.string "firstname"
            t.string "lastname"
            t.string "email"
            t.string "remember_token", :limit => 40
            t.datetime "remember_token_expires_at"
            t.string "password_digest"
            t.string "password_reset_code"
    #        t.string "salt", :limit => 40
            t.integer "account_id"
            t.datetime "last_login_at"
            
            t.timestamps
        end
        add_index "users", ["account_id"]
    end
end
