class AddIndexToInvoiceNumber < ActiveRecord::Migration
  def change
    add_index :invoices, [:invoice_number]
  end
end
