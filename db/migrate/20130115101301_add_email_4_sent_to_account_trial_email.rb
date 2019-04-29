class AddEmail4SentToAccountTrialEmail < ActiveRecord::Migration
  def change
    add_column :account_trial_emails, :email_4_sent, :boolean, :default => false
  end
end
