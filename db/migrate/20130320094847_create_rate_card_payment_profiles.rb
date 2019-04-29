class CreateRateCardPaymentProfiles < ActiveRecord::Migration
  def change
    create_table :rate_card_payment_profiles do |t|
      t.integer :payment_profile_id, :rate_card_id
      t.integer :percentage, :default => 0
      t.timestamps
    end
    add_index :rate_card_payment_profiles, [:rate_card_id, :payment_profile_id], :name => 'rate_card_profile_in1'
    add_index :rate_card_payment_profiles, [:payment_profile_id, :rate_card_id], :name => 'rate_card_profile_in2'
  end
end
