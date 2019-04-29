class CreateAccountSettings < ActiveRecord::Migration
    def change
        create_table :account_settings do |t|
            t.integer "account_id"
            t.boolean "reached_limit_email_sent", :default => false
            t.timestamps
        end
        add_index "account_settings", ["account_id"]
    end
end
