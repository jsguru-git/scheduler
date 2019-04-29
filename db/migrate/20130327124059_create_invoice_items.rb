class CreateInvoiceItems < ActiveRecord::Migration
  def change
    
    create_table :invoice_items do |t|
      t.string :name
      t.integer :amount_cents, :default => 0
      t.integer :quantity, :default => 1
      t.boolean :vat, :default => true
      t.integer :invoice_id, :payment_profile_id
      t.timestamps
    end
    
    add_index :invoice_items, [:invoice_id, :payment_profile_id]
    add_index :invoice_items, [:payment_profile_id, :invoice_id]
  end
end
