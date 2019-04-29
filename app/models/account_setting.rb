class AccountSetting < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  belongs_to :account
  belongs_to :common_project, :foreign_key => 'common_project_id', :class_name => 'Project'


  # Validation
  validates :account_id, :presence => true
  validates :invoice_alert_email, :expected_invoice_mail_email, :schedule_mail_email, :rollover_alert_email, :stale_opportunity_email, :budget_warning_email, email: true
  validates :schedule_mail_frequency, :expected_invoice_mail_frequency, :inclusion => { :in => SELECTIONS['mail_frequency'].keys }
  validates :issue_tracker_username, length: { minimum: 2, maximum: 100 }, allow_blank: true, if: Proc.new { |account_setting| account_setting.updating_issue_tracker_credentails.present? }
  validates :issue_tracker_password, length: { minimum: 2, maximum: 100 }, allow_blank: true, if: Proc.new { |account_setting| account_setting.updating_issue_tracker_credentails.present? }
  validates :issue_tracker_url, length: { minimum: 2, maximum: 255 }, allow_blank: true, url: true, if: Proc.new { |account_setting| account_setting.updating_issue_tracker_credentails.present? }
  validate :check_start_time_is_less_than_end_time
  validate :check_associated
  validate :at_least_one_working_day_selected
  validate :check_logo_content_type


  # Nested models


  # Callbacks
  before_validation :remove_whitespace
  before_update :encrypt_form_fields


  # ActiveRecord Store
  store :working_days, accessors: [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]


  # Mass assignment protection
  attr_accessible :reached_limit_email_sent, :working_day_end_time, :working_day_start_time, :default_currency, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :invoice_alert_email, :schedule_mail_email, :schedule_mail_frequency, :expected_invoice_mail_email, :expected_invoice_mail_frequency, :logo, :rollover_alert_email, :budget_warning_email, :stale_opportunity_email, :issue_tracker_username, :issue_tracker_password, :issue_tracker_url, :hopscotch_enabled
  
  
  # Virtual attr
  attr_accessor :updating_issue_tracker_credentails
  
  
  # Logos
  has_attached_file :logo, :styles => { :thumb => '60x60#', :normal => 'x100' },
                           :path => "/:attachment/:id_partition/:fingerprint/:style/:filename",
                           :default_url => '/assets/tool/layout/logo_background.png'

  #
  # Mark account as the plan limit warning email as being sent
  def mark_as_reached_limit_email_sent
    self.update_attributes(:reached_limit_email_sent => true)
  end


  #
  # Un-ark account as the plan limit warning email as being sent
  def mark_as_reached_limit_email_not_sent
    self.update_attributes(:reached_limit_email_sent => false)
  end


  #
  # Counts up the number of days that are worked per week
  def number_of_days_worked_in_a_week
    count = 0
    self.working_days.each do |day|
      count += 1 if day[1] == '1'
    end
    count
  end

  #
  # Return the working day duration in minutes
  def working_day_duration_minutes
    ((self.working_day_end_time - self.working_day_start_time) / 60).to_i
  end

  # Work out the number of hours worked in a week for a given account
  def number_of_minutes_worked_in_a_week
    self.working_day_duration_minutes * self.number_of_days_worked_in_a_week
  end


  # Work out the number of mins worked in a month
  def number_of_minutes_worked_in_a_month
    ((self.number_of_minutes_worked_in_a_week / 7) * 30).to_i
  end

  # Public: Expected Timings for a day in minutes
  #
  # date - Date of work
  #
  # Return the expect Timings in minutes
  def expected_minutes_worked(date)
    working_days[date.strftime('%A').downcase.to_sym] == "1" ? working_day_duration_minutes : 0
  end

#
# Create methods
#


  # Check that the start time is > the end time
  def check_start_time_is_less_than_end_time
    if self.working_day_end_time.present? && self.working_day_start_time.present?
		  errors.add(:working_day_end_time, "can't be before the working day start date") if self.working_day_start_time >= self.working_day_end_time
	  end
  end


  # Check to see that the given task id belongs to the correct account
  def check_associated
    if self.common_project_id.present? && self.account.present?
      project = self.common_project
      errors.add(:common_project_id, "does not exist") if self.account_id != project.account_id
    end
  end


  # Should check that at least one working day has been selected in the account settings
  def at_least_one_working_day_selected
    errors.add(:working_days, "must be selected for at least one day") if self.number_of_days_worked_in_a_week == 0
  end

  def check_logo_content_type
    errors.add(:logo, 'must be a jpg or png') unless ['image/jpeg', 'image/png'].include?(self.logo_content_type) || self.logo_content_type.nil?
  end


#
# General methods
#


#
# Mail methods
#

  
  # Sends the scheudle emails as defined in the account settings.
  def self.send_schedule_mail
    account_settings = AccountSetting.where(["schedule_mail_email IS NOT ?", nil])
    
    account_settings.each do |account_setting|
      if account_setting.should_send_email?(:schedule)
        
        if account_setting.schedule_mail_frequency == 0
          start_date = Date.today
          end_date = Date.today
        elsif account_setting.schedule_mail_frequency == 1
          start_date = Time.now.beginning_of_week.to_date
          end_date = Time.now.end_of_week.to_date
        elsif account_setting.schedule_mail_frequency == 2
          start_date = Time.now.beginning_of_month.to_date
          end_date = Time.now.end_of_month.to_date
        end
        
        ScheduleMailer.schedule_mail(account_setting.account, account_setting.account.teams, account_setting.schedule_mail_email, start_date, end_date).deliver
        
        # Set to 10 mins in the past as the scheudled job only runs once a day and dont want to miss out on next day due to running a few seconds sooner.
        account_setting.schedule_mail_last_sent_at = (Time.now - 10.minutes)
        account_setting.save!
      end
    end
  end
  
  
  # Sends the expected invoice emails as defined in the account settings
  def self.send_expected_invoice_mail
    account_settings = AccountSetting.where(["expected_invoice_mail_email IS NOT ?", nil])
    
    account_settings.each do |account_setting|
      if account_setting.should_send_email?(:expected_invoice)
        Money.default_currency = Money::Currency.new(account_setting.default_currency)
        
        if account_setting.expected_invoice_mail_frequency == 0
          start_date = Date.today
          end_date = Date.today
        elsif account_setting.expected_invoice_mail_frequency == 1
          start_date = Time.now.beginning_of_week.to_date
          end_date = Time.now.end_of_week.to_date
        elsif account_setting.expected_invoice_mail_frequency == 2
          start_date = Time.now.beginning_of_month.to_date
          end_date = Time.now.end_of_month.to_date
        end
        
        payment_profiles = PaymentProfile.un_invoiced_expected_for_between_dates(start_date, end_date).order('projects.business_owner_id, payment_profiles.expected_payment_date')
        InvoiceMailer.expected_invoice_mail(account_setting.account, account_setting.schedule_mail_email, payment_profiles, start_date, end_date).deliver

        # Set to 10 mins in the past as the scheudled job only runs once a day and dont want to miss out on next day due to running a few seconds sooner.
        account_setting.expected_invoice_mail_last_sent_at = (Time.now - 10.minutes)
        account_setting.save!
        
        # Reset after
        Money.default_currency = Money::Currency.new('USD')
      end
    end
  end

  
  # Checks to see if account should recieve another email
  # Params:
  # which_mail {symbol} which email to consider
  def should_send_email?(which_mail)
    return false if self.send("#{which_mail}_mail_email").blank?
    
    if self.send("#{which_mail}_mail_frequency") == 0
      # Daily
      return true if self.send("#{which_mail}_mail_last_sent_at").blank? || (Time.now - 1.day) > self.send("#{which_mail}_mail_last_sent_at")
    elsif self.send("#{which_mail}_mail_frequency") == 1
      # Weekly
      if Date.today.wday == 1
        return true if self.send("#{which_mail}_mail_last_sent_at").blank? || (Time.now - 1.week) > self.send("#{which_mail}_mail_last_sent_at")
      end
    elsif self.send("#{which_mail}_mail_frequency") == 2
      # Monthly
      if Date.today.day == 1
        return true if self.send("#{which_mail}_mail_last_sent_at").blank? || (Time.now - 1.month) > self.send("#{which_mail}_mail_last_sent_at")
      end
    end
    
    false
  end
  
  
#
# encryption
#

  # Public: encrypt issue tracker details
  def encrypt_form_fields
    # check if we are updating api details
    if self.updating_issue_tracker_credentails.present?
      p = PGP.new
      self.issue_tracker_username = p.encrypt(self.issue_tracker_username) if self.issue_tracker_username.present?
      self.issue_tracker_password = p.encrypt(self.issue_tracker_password) if self.issue_tracker_password.present?
    end
  end

  # Public: decrypt issue tracker details
  def decrypt_fields
    p = PGP.new
    self.issue_tracker_username = p.decrypt(self.issue_tracker_username) if self.issue_tracker_username.present?
    self.issue_tracker_password = p.decrypt(self.issue_tracker_password) if self.issue_tracker_password.present?
  end

  # Public: decrypt issue tracker username
  def issue_tracker_username_raw
    if self.issue_tracker_username.present?
      p = PGP.new
      p.decrypt(self.issue_tracker_username)
    end
  end

  # Public: decrypt issue tracker password
  def issue_tracker_password_raw
    if self.issue_tracker_password.present?
      p = PGP.new
      p.decrypt(self.issue_tracker_password)
    end
  end
  
end
