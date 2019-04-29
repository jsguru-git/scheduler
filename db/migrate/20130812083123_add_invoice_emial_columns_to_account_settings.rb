class AddInvoiceEmialColumnsToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :expected_invoice_mail_email, :string
    add_column :account_settings, :expected_invoice_mail_frequency, :integer, :default => 1
    add_column :account_settings, :expected_invoice_mail_last_sent_at, :datetime
  end
end
