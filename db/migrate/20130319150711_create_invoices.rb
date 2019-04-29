class CreateInvoices < ActiveRecord::Migration
  
  def change
    create_table :invoices do |t|
      t.integer :project_id, :total_amount_cents_exc_vat, :total_amount_cents_inc_vat
      t.integer :invoice_status, :default => 0
      t.date :invoice_date, :due_on_date
      t.string :invoice_number, :terms, :po_number, :currency
      t.decimal :vat_rate, :precision => 10, :scale => 2
      t.text :address, :payment_methods, :notes
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.timestamps
    end
    
    add_index :invoices, [:project_id]
  end
  
end
