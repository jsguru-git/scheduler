class AddAllocatedAtToInvoiceUsages < ActiveRecord::Migration
  def change
    add_column :invoice_usages, :allocated_at, :date
  end
end
