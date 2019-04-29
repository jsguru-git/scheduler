class AddUserIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :user_id, :integer
    add_index :invoices, [:user_id]
  end
end
