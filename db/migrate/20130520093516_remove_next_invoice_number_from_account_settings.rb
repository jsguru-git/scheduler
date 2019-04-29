class RemoveNextInvoiceNumberFromAccountSettings < ActiveRecord::Migration
  def up
    remove_column :account_settings, :next_invoice_number
  end
  
  def down
    add_column :account_settings, :next_invoice_number, :integer, :default => 1
  end
end
