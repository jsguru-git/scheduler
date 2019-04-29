class CreateInvoiceUsages < ActiveRecord::Migration
  def change
    create_table :invoice_usages do |t|
      t.string :name
      t.integer :invoice_id, :user_id, :amount_cents
      t.timestamps
    end
    
    add_index :invoice_usages, [:invoice_id]
    add_index :invoice_usages, [:user_id]
  end
end
