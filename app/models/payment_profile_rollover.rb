class PaymentProfileRollover < ActiveRecord::Base
  
  
  # External libs
  

  # Relationships
  belongs_to :account
  belongs_to :project
  belongs_to :payment_profile
  belongs_to :user


  # Validation
  validates :old_expected_payment_date, :new_expected_payment_date, :reason_for_date_change, :account_id, presence: true
  

  # Callbacks
  after_create :send_email
  

  # Mass assignment protection
  attr_accessible :old_expected_payment_date, :new_expected_payment_date, :reason_for_date_change
  

  # Plugins


#
# Extract functions
#


  # Named scopes


#
# Save functions
#


#
# Create functions
#

  
  # Create a new entry for a payment profile
  #
  # payment_profile {PaymentProfile} A recently updated payment profile instance
  def self.create_entry(payment_profile)
    if payment_profile.expected_payment_date_changed?
      p_p_rollover = PaymentProfileRollover.new(reason_for_date_change: payment_profile.reason_for_date_change, old_expected_payment_date: payment_profile.changes[:expected_payment_date][0], new_expected_payment_date: payment_profile.expected_payment_date)
      p_p_rollover.payment_profile_id = payment_profile.id
      p_p_rollover.project_id         = payment_profile.project_id
      p_p_rollover.account_id         = payment_profile.project.account_id
      p_p_rollover.user_id            = payment_profile.last_saved_by_id
      p_p_rollover.save!
    end
  end

  # Returns PaymentProfiles rolled over in to a particular month
  #
  # months_from_now - Number of months from Today. (Default: 0)
  #
  # Returns an Array
  def self.profiles_rolled_over_in_to_month(months_from_now = 0)
    results = PaymentProfile.where(payment_profile_rollovers:
                                    { new_expected_payment_date: (Date.today + months_from_now.months).beginning_of_month...(Date.today + months_from_now.months).end_of_month })
                            .joins(:payment_profile_rollovers)
  end


#
# Update functions
#


#
# General functions
#
  

protected


  # Protected: Send an email with informaiton about the rollover
  def send_email
    if self.account.account_setting.rollover_alert_email.present?
      PaymentProfileMailer.new_rollover_alert(self, self.account.account_setting.rollover_alert_email).deliver
    end
  end

  
end