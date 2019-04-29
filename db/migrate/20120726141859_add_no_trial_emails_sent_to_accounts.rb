class AddNoTrialEmailsSentToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :no_trial_emails_sent, :integer, :default => 0
  end
end
