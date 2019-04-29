class AddRolloverAlertEmailToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :rollover_alert_email, :string
  end
end
