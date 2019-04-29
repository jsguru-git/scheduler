class Account < ActiveRecord::Base

  # External libs
  include SharedMethods


  # Relationships
  belongs_to :account_plan

  has_many :account_account_components, :dependent => :destroy
  has_many :account_components, :through => :account_account_components

  has_many   :users,           :dependent => :destroy
  has_one    :account_setting, :dependent => :destroy
  has_one    :account_trial_email, :dependent => :destroy
  has_many   :teams,           :dependent => :destroy
  has_many   :projects,        :dependent => :destroy
  has_many   :clients,         :dependent => :destroy
  has_many   :entries,         :dependent => :destroy
  has_many   :rate_cards,      :dependent => :destroy
  has_many   :invoice_deletions, :dependent => :destroy
  has_many   :quote_default_sections, :dependent => :destroy
  has_many   :payment_profile_rollovers, :dependent => :destroy
  has_many   :phases,          :dependent => :destroy


  # Validation
  validates :site_address, :account_plan_id, :presence => true
  validates_uniqueness_of :site_address, :case_sensitive => false
  validates :site_address, :length => { :minimum => 2, :maximum => 35 }, :allow_blank => true
  validates :site_address, :exclusion => { :in => RESERVED_SUBDOMAINS, :message => 'has already been taken' }

  # Check subdomain only consists of a-z, 0-9 and underscores and is a valid url.
  validates_each :site_address do |model, attr_name, attr_value|
    # Allowed chars
    # 65 - 90 uppercase
    # 97 - 122 lowercase
    # 48 - 57 numbers
    # 95 _
    attr_value.to_s.each_byte do |ts_charNo|
      if !((ts_charNo >= 48 && ts_charNo <= 57) || (ts_charNo >= 97 && ts_charNo <= 122))
        model.errors.add(attr_name, "contains invalid characters (it should only contain letters and numbers)")
        break
      end
    end
  end


  # Nested models
  accepts_nested_attributes_for :users


  # Virtual attributes


  # Callbacks
  before_validation :remove_whitespace
  before_create :set_trial_expires_at
  after_create :after_create_tasks


  # Mass assignment protection
  attr_accessible :site_address, :users_attributes


  # Plugins


#
# Extract functions
#


  # Default scope


  # Named scopes



  #
  # Find an active account
  def self.find_active_account(subdomain)
    self.find(:first, :conditions => ['site_address = ? AND account_deleted_at IS ?', subdomain, nil]) unless subdomain.blank?
  end


#
# Save functions
#


  #
  #
  def site_address=(value)
    write_attribute :site_address, (value ? value.downcase : nil)
  end


  #
  # Assign account rights to a user
  def assign_role_to_user
    self.users.first.make_account_holder(false)
  end


  #
  #
  def update_plan_to(plan_id)
    self.account_plan_id = plan_id
    if self.exceeded_limit?
      return false
    else
      self.update_subscription_in_chargify unless self.chargify_customer_id.blank?
      self.save!
      return true
    end
  end


  # 
  # Returns true if limit has been exceeded
  def exceeded_limit?
    table_names = AccountPlan.get_limit_model_types

    table_names.each do |table_name|
      if self.limit_exceeded_for?(table_name.camelize)
        return true
      end
    end

    return false
  end


  #
  # Return true if a limit has been reached
  def reached_limit?
    table_names = AccountPlan.get_limit_model_types

    table_names.each do |table_name|
      if self.limit_reached_for?(table_name.camelize)
        return true
      end
    end

    return false
  end


  #
  #
  def limit_reached_for?(class_name)
    current_count = class_name.camelize.constantize.count(:conditions => ["account_id = ?", self.id])
    table_name = class_name.camelize.constantize.table_name

    if self.account_plan.send('no_' + table_name) != nil && current_count >= self.account_plan.send('no_' + table_name)
      return true
    else
      return false
    end
  end


  #
  # Returns true if the limit has been exceeded
  def limit_exceeded_for?(class_name)
    current_count = class_name.camelize.constantize.count(:conditions => ["account_id = ?", self.id])
    table_name = class_name.camelize.constantize.table_name

    if self.account_plan.send('no_' + table_name) != nil && current_count > self.account_plan.send('no_' + table_name)
      return true
    else
      return false
    end
  end


  #
  # Check if a given component id is active for the given account
  def component_enabled?(component_id)
    AccountAccountComponent.exists?(["account_id = ? AND account_component_id = ?", self.id, component_id])
  end


#
# General functions
#


  #
  # Identifies if anyone has logged into this account before
  def first_login?
    if self.users.length == 1 && !self.users.first.last_login_at
      return true
    else
      return false
    end
  end


  #
  #
  def count_for_model(class_name)
    class_name.camelize.constantize.count(:conditions => ["account_id = ?", self.id])
  end




  # Send emails to people who are currently using the trial trying to get them to signup. (one at 15 days till expiry and one on 2 days till expiry)
  def self.send_trial_emails
    trial_accounts = Account.where(['account_deleted_at IS ? AND chargify_customer_id IS ?', nil, nil]).all
    if trial_accounts.present?
      for account in trial_accounts
        account.account_trial_email.deliver_trial_emails
      end
    end
  end


  # Find the common_project for an account
  def common_project
    self.account_setting.common_project
  end


  #
  # Chargify
  #


  #
  # return the chargify subscription if one exists
  def chargify_subscription
    return nil if self.chargify_customer_id.blank?
    begin
      Chargify::Subscription.find_by_customer_reference(self.id)
    rescue
      return nil
    end
  end


  #
  #
  def chargify_hosted_signup_link
    chargify_subscription = self.chargify_subscription
    return nil if chargify_subscription.blank?

    token = Digest::SHA1.hexdigest("update_payment--#{chargify_subscription.id}--#{APP_CONFIG['chargify']['shared_key']}")[0..9]
    "http://#{APP_CONFIG['chargify']['subdomain']}.chargify.com/update_payment/#{chargify_subscription.id}/#{token}"
  end


  #
  # Returns all statements for the subscription
  def get_statements
    if self.chargify_customer_id.blank? || Rails.env == "test"
      []
    else
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(self.id)
      chargify_subscription.statements
    end
  end


  #
  # Gets a single statement for an account
  def get_single_statement(statement_id)
    chargify_subscription = Chargify::Subscription.find_by_customer_reference(self.id)
    chargify_subscription.statement(statement_id)
  end
    
  #
  # Chargify update methods
  #


  #
  # Update account details with them within chargify (We re-request the data from chargify to make sure that its real)
  def self.update_from_webhook_callback(chargify_subscription_id)
    chargify_subscription = Chargify::Subscription.find(chargify_subscription_id)
    account = Account.find(chargify_subscription.customer.reference)

    account.sync_with_chargify unless account.blank?
  end


  #
  #
  def sync_with_chargify
    if Rails.env != "test"
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(self.id)

      # Update stored chargify customer id
      new_chargify_user = self.update_account_chargify_id(chargify_subscription.customer)
      
      # Update account state
      self.update_account_state(chargify_subscription)

      # Update account plan
      self.update_plan_by_handle(chargify_subscription.product.handle)
      
      # Update components
      if new_chargify_user
        # Force update components in chargify as this is the first callback and we dont pass this info over on hosted pages
        self.force_setting_components

        # Send welcome email
        holder = User.account_holder_for_account(self)
        AccountMailer.purchase_complete(self, holder).deliver
      else
        self.update_components_from_chargify(chargify_subscription)
      end

      # Update user
      self.update_account_holder(chargify_subscription.customer)
    end
  end


  #
  # Check the componenets and set the same values locally
  def update_components_from_chargify(chargify_subscription)
    chargify_components = chargify_subscription.components
    if chargify_components.present?
      for chargify_comp in chargify_components

        account_component = AccountComponent.find_by_chargify_component_number(chargify_comp.id)
        if account_component.present?
          if chargify_comp.enabled
            account_component.enable_for(self)
          else
            account_component.disable_for(self)
          end
        end

      end
    end
  end


  #
  # update the stored chargify customer id
  def update_account_chargify_id(customer)
    if self.chargify_customer_id.blank?
      self.chargify_customer_id = customer.id
      self.save!
      return true
    end
    return false
  end


  #
  # Force update components in chargify
  def force_setting_components
    if self.account_components.present?
      for component in self.account_components
        component.enable_in_chargify_for(self)
      end
    end
  end


  #
  # updates the account plan based on the product handle that has been passed in
  def update_plan_by_handle(chargify_product_handle)
    account_plan = AccountPlan.find_by_chargify_product_handle(chargify_product_handle)
    self.account_plan_id = account_plan.id
    self.save!
  end


  #
  # Update the account state
  def update_account_state(chargify_subscription)
    if chargify_subscription.state == 'canceled' || chargify_subscription.state == 'expired' || chargify_subscription.state == 'suspended'
      self.account_suspended = true
      self.account_deleted_at = Time.now.utc
      self.save!
    else
      self.account_suspended = false
      self.account_deleted_at = nil
      self.save!
    end
  end


  #
  #
  def update_account_holder(chargify_customer)
    account_user = User.account_holder_for_account(self)
    account_user.update_attributes( :firstname => chargify_customer.first_name, :lastname => chargify_customer.last_name, :email => chargify_customer.email)
  end


  #
  # update the subscription in chargify, no proration is wanted
  def update_subscription_in_chargify
    if Rails.env != "test"
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(self.id)
      chargify_subscription.product_handle = self.account_plan.chargify_product_handle
      chargify_subscription.save
    end
  end


#
# Delete
#


  #
  # marks an account that is should be deleted
  def mark_to_be_deleted
    # update chargify
    if Rails.env != "test" && !self.chargify_customer_id.blank?
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(self.id)
      chargify_subscription.cancel
    end

    # update database
    self.account_deleted_at = Time.now.utc
    self.save(:validate => false)
  end


  # Suspend a users account
  def suspend_account
    self.account_suspended = true
    self.save(:validate => false)
  end


  #
  # Destroys accounts that have been scheduled for deletion
  def self.destroy_marked_accounts
    self.destroy_all(['account_deleted_at IS NOT ? AND account_deleted_at < ?', nil, 4.weeks.ago])
  end


  #
  # Delete any accounts that have expired their trial periods
  def self.delete_expired_trial_accounts
    # Suspend accounts for two weeks
    accounts = Account.where(['account_deleted_at IS ? AND account_suspended = ? AND chargify_customer_id IS ? AND trial_expires_at < ?', nil, false, nil, Time.now]).all
    if accounts.present?
      for account in accounts
        account.suspend_account
        # Send email letting user know about their canceled account
        account.account_trial_email.send_trial_expired_email
      end
    end

    # Delete accounts 2 weeks later
    accounts = nil
    accounts = Account.where(['account_deleted_at IS ? AND account_suspended = ? AND chargify_customer_id IS ? AND DATE_ADD(trial_expires_at, INTERVAL 2 WEEK) < ?', nil, true, nil, Time.now]).all
    if accounts.present?
      for account in accounts
        account.mark_to_be_deleted
      end
    end
  end


protected


  # Set expiry date
  def set_trial_expires_at
    self.trial_expires_at = 30.days.from_now
  end


  # tasks to call after callback
  def after_create_tasks
    self.assign_role_to_user
    self.create_associated_settings
    self.create_associated_trial_email
    self.create_default_quote_sections
    Project.create_default_internal_projects(self)
  end

  # Create the quote default sections
  def create_default_quote_sections
    self.quote_default_sections.create!(title: 'Summary')
    
    quote_default_section = self.quote_default_sections.new(title: 'Costs')
    quote_default_section.cost_section = 1
    quote_default_section.save!
    
    self.quote_default_sections.create!(title: 'Disclaimer')
  end

  # Creates an instance of account settings for this account
  def create_associated_settings
    account_setting = AccountSetting.new
    account_setting.account_id = self.id
    account_setting.attributes = {:sunday => '0', :monday => '1', :tuesday => '1', :wednesday => '1', :thursday => '1', :friday => '1', :saturday => '0', :hopscotch_enabled => '1' }
    account_setting.save!
  end


  # Creates an instance of account settings for this account
  def create_associated_trial_email
    account_trial_email = AccountTrialEmail.new
    account_trial_email.account_id = self.id
    account_trial_email.save!
  end


end
