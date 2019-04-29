class CreatePaymentProfileRollovers < ActiveRecord::Migration
  def change
    create_table :payment_profile_rollovers do |t|
      t.text :reason_for_date_change
      t.date :old_expected_payment_date, :new_expected_payment_date
      t.integer :payment_profile_id, :project_id, :account_id, :user_id
      t.timestamps
    end
    
    add_index :payment_profile_rollovers, [:payment_profile_id]
    add_index :payment_profile_rollovers, [:project_id]
    add_index :payment_profile_rollovers, [:account_id]
    add_index :payment_profile_rollovers, [:user_id]
  end
end
