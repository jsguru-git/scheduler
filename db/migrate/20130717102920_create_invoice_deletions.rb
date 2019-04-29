class CreateInvoiceDeletions < ActiveRecord::Migration
  def change
    create_table :invoice_deletions do |t|
      t.integer :project_id, :account_id, :user_id, :default_currency_total_amount_cents_exc_vat
      t.string :invoice_number
      t.date :invoice_date
      t.timestamps
    end
    
    add_index :invoice_deletions, [:user_id]
    add_index :invoice_deletions, [:account_id]
    add_index :invoice_deletions, [:project_id]
  end
end
