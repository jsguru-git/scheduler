# Simple model that keeps track of what trial emails have been sent
# email_1_sent - 15 days to trial expiry
# email_2_sent - 2 days to expiry if account used
# email_3_sent - 2 days to expiry if account not used
# email_4_sent - 5 days after expiry/suspension
# trial_path == 1 = Account used path
# trial path == 2 = Account not used path
class AccountTrialEmail < ActiveRecord::Base


  # External libs


  # Relationships
  belongs_to :account


  # Validation
  validates :account_id, :presence => true


  # Plugins


  # Callbacks


  # Mass assignment protection
  attr_accessible :email_1_sent, :email_2_sent, :email_3_sent, :email_4_sent, :trial_path


#
# Extract methods
#

  # Named scopes



#
# Create methods
#


#
# Update methods
#


#
# Save methods
#


#
# General methods
#

  # Deliver trial emails
  def deliver_trial_emails
    if !self.email_1_sent?
      # Send 15 days before end of trial
      self.send_15_days_till_expire_email if !self.account.account_suspended? && self.account.trial_expires_at.present? && self.account.trial_expires_at < 15.days.from_now
    elsif !self.account.account_suspended?
      # Send 2 days before end of trial
      self.send_2_days_till_expire_email if self.account.trial_expires_at.present? && self.account.trial_expires_at < 2.days.from_now
    elsif self.account.account_suspended?
      # Send 5 days after expiry
      self.send_non_user_feedback_request if self.account.trial_expires_at.present? && self.account.trial_expires_at < 5.days.ago
    end
  end


  # Sends 15 days before the trial ends to the account holder
  def send_15_days_till_expire_email
    unless self.email_1_sent?
      holder = User.account_holder_for_account(self.account)
      AccountMailer.trial_email_1(self.account, holder).deliver
      self.update_attribute(:email_1_sent, true)
    end
  end


  # Sends 2 days before the trial ends to teh account holder
  def send_2_days_till_expire_email
    holder = User.account_holder_for_account(self.account)

    # Different email depending on if a user has used their account
    if self.account.users.length <= 1 && self.account.projects.length <= 1
      unless self.email_3_sent?
        # Reset trial date if first time in here
        self.account.trial_expires_at = 14.days.from_now
        self.account.save(:validate => false)
        AccountMailer.trial_email_3(self.account, holder).deliver

        self.update_attributes(:email_3_sent => true, :trial_path => 2)
      end
    else
      AccountMailer.trial_email_2(self.account, holder).deliver unless self.email_2_sent?
      self.update_attributes(:email_2_sent => true, :trial_path => 1)
    end
  end


  # Sends when a trial account is disabled TODO test
  def send_trial_expired_email
    if self.trial_path.present? && self.trial_path == 1
      holder = User.account_holder_for_account(account)
      AccountMailer.trial_expired(account, holder).deliver
    end
  end


  # Sends when trial has expired and it looks like they are not going to continue use.
  def send_non_user_feedback_request
    unless self.email_4_sent?
      holder = User.account_holder_for_account(self.account)
      AccountMailer.non_user_feedback_request(self.account, holder).deliver
      self.update_attributes(:email_4_sent => true)
    end
  end


protected


end
