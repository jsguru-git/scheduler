class AddDefaultCurrencyTotalAmountCentsToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :default_currency_amount_cents, :integer
  end
end
