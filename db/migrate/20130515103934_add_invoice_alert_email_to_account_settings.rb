class AddInvoiceAlertEmailToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :invoice_alert_email, :string
  end
end
