class CreateAccounts < ActiveRecord::Migration
  def change
        create_table :accounts do |t|
            t.string "site_address"
            t.datetime "account_deleted_at"
            t.boolean "account_suspended", :default => false
            t.integer "account_plan_id"
            t.boolean "signup_complete", :default => false
            t.integer "chargify_customer_id"
            t.timestamps
        end

      add_index "accounts", ["account_plan_id"]
      add_index "accounts", ["chargify_customer_id"], :unique => true
      add_index "accounts", ["site_address"], :unique => true
  end
end
