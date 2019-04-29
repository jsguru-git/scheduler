class CreateAccountTrialEmails < ActiveRecord::Migration
  def up
    create_table :account_trial_emails do |t|
      t.integer :account_id, :trial_path
      t.boolean :email_1_sent, :email_2_sent, :email_3_sent, :default => false
      
      t.timestamps
    end
    
    # Update existing accounts
    for account in Account.all
      account_trial_email = AccountTrialEmail.new
      account_trial_email.account_id = account.id
      account_trial_email.save!
      
      if account.no_trial_emails_sent == 1
        account.account_trial_email.update_attributes(:email_1_sent => true)
      elsif account.no_trial_emails_sent == 2
        account.account_trial_email.update_attributes(:email_3_sent => true, :email_1_sent => true, :trial_path => 2)
      end
    end
    
    remove_column :accounts, :no_trial_emails_sent
  end
  
end
