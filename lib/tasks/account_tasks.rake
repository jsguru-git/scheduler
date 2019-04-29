namespace :account do

  # Deletes accounts that have been canceled by the user
  task(:delete_marked_accounts => :environment) do
    Account.destroy_marked_accounts
  end


  # Delete accounts where trial periods have expired
  task(:delete_expired_trial_periods => :environment) do
    Account.delete_expired_trial_accounts
  end
  
  
  # Send out trial period warning emails
  task(:send_trial_emails => :environment) do
    Account.send_trial_emails
  end
  
  
  # Send the required mail out for accounts
  task(:send_account_mail => :environment) do
    AccountSetting.send_schedule_mail
    AccountSetting.send_expected_invoice_mail
  end
  
end
