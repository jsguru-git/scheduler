class AddScheuleMailEmailToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :schedule_mail_email, :string
    add_column :account_settings, :schedule_mail_frequency, :integer, :default => 1
    add_column :account_settings, :schedule_mail_last_sent_at, :datetime
  end
end
