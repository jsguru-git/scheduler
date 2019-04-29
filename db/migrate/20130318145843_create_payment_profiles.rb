class CreatePaymentProfiles < ActiveRecord::Migration
  def change
    create_table :payment_profiles do |t|
      t.integer :project_id, :expected_cost_cents
      t.decimal :expected_minutes, :precision => 20, :scale => 2
      t.string :name
      t.date :expected_payment_date
      t.boolean :generate_cost_from_time, :default => false
      t.timestamps
    end
    
    add_index :payment_profiles, [:project_id]
  end
end