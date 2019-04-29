class CreateAccountPlans < ActiveRecord::Migration
    def change
        create_table :account_plans do |t|
            t.string "name"
            t.string "description"
            t.integer "price_in_cents"
            t.string "chargify_product_handle"
            t.integer "chargify_product_number"
            t.boolean "show_plan", :default => true
            t.timestamps
            t.integer "no_users"
        end

        add_index "account_plans", ["name"]
    end
end
