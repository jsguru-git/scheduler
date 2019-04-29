class AddEmailToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :email, :string
  end
end
