require 'digest/sha1'

class User < ActiveRecord::Base

  # External libs
  include AuthenticationLogic
  include SharedMethods
  include PlanChecker
  include Gravtastic
  include Icalendar

  gravtastic

  # Relationships
  delegate :common_project, :to => :account

  belongs_to :account
  has_and_belongs_to_many :roles

  has_many :team_users, :dependent => :destroy
  has_many :teams, :through => :team_users

  has_many :entries, :dependent => :destroy
  has_many :timings, :dependent => :destroy
  has_many :projects, :foreign_key => "business_owner_id", :dependent => :nullify
  has_many :project_manager_projects, :foreign_key => "project_manager_id", :class_name => "Project", :dependent => :nullify
  has_many :oauth_drive_tokens, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :document_comments, :dependent => :nullify
  has_many :project_comments, :dependent => :nullify
  has_one  :api_key, :dependent => :destroy
  has_many :quotes, :dependent => :nullify
  has_many :saved_quotes, :foreign_key => 'last_saved_by_id', :dependent => :nullify, :class_name => 'Quote'
  has_many :invoices, :dependent => :nullify
  has_many :invoice_deletions, :dependent => :nullify
  has_many :invoice_usages, :dependent => :nullify
  has_many :payment_profile_rollovers, :dependent => :nullify


  # Validation
  validates :firstname, :lastname, :email, :presence => true
  validates :firstname, :lastname, :email, :length => { :maximum => 255 }, :allow_blank => true

  validates_uniqueness_of :email, :case_sensitive => false,
                                  :message => "has already been registered",
                                  :scope => [:account_id]

  validates_format_of :email, :allow_blank => true,
                              :message => 'is not a valid format',
                              :with => /\A([A-z0-9\.\-_]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates :password, :length => { :minimum => 6, :maximum => 35 }, :allow_blank => true
  validate :check_account_holder_exists



  # Check plan limit
  validate do
    if self.new_record? && self.has_reached_plan_limit?
      self.errors.add(:plan, "limit has been reached, you either need to ask the account holder to upgrade or remove some existing users")
    end
  end


  # Password
  has_secure_password


  # Callbacks
  before_validation :remove_whitespace
  before_create :assign_api_key!


  # Mass assignment protection
  attr_accessible  :email, :firstname, :lastname, :password, :password_confirmation, :last_login_at, :time_zone, :archived, :users, :number_of_logins


  # Named scopes
  scope :name_ordered, order('users.firstname, users.lastname')
  scope :not_archived, where(["archived = ?", false])
  

  # Custom json output. Alternative would be using Active Model serializers
  def serializable_hash(opts = {})
    options = {
      :only => [:id, :email, :account_id, :firstname, :lastname, :biography]
    }.update(opts)
    super(options)
  end

  # Users time zone offset in hours
  # If timezone is nil in the db then return UTC offset
  # Returns Integer
  def zone_offset_hours
    zone = ActiveSupport::TimeZone.new(self.time_zone || "UTC")
    (zone.utc_offset / 60) / 60
  end


  #
  # find the most recently logged in users
  def self.most_recent_login(account)
    account.users.find(:all, :conditions => ['last_login_at IS NOT ?', nil],
                             :order => 'last_login_at DESC',
                             :limit => 4)
  end


  # Returns boolean true if a user has a component
  def has_component?(component_id)
    self.account.component_enabled?(component_id)
  end


  #
  # provide fullname
  def name
    "#{self.firstname} #{self.lastname}"
  end


  # Returns first name plus the first letter of surname
  def name_truncated
    if self.lastname.present?
      return "#{self.firstname} #{self.lastname[0]}"
    else
      return self.firstname
    end
  end


  # Get the account holder for a given account
  def self.account_holder_for_account(account)
    account.users.find(:first, :conditions => ["roles.title = ?", 'account_holder'], :include => [:roles])
  end


  # Check to see if the current user is the account holder
  def is_account_holder?
    roles.any? { |r| r.title == 'account_holder' }
  end


  # Check to see if the current user is a admin
  def is_administrator?
    roles.any? { |r| r.title == 'administrator' }
  end


  # Check to see if the current user is an account holder or admin
  def is_account_holder_or_administrator?
    roles.any? { |r| r.title == 'administrator' || r.title == 'account_holder' }
  end

  # Public: Check if a User has one of several roles
  #
  # check_roles - Array of Role titles
  #
  # Returns a Boolean
  def includes_role?(check_roles)
    !!(roles.map(&:title) & check_roles).present?
  end


  # Finds projects scheduled for the current user between two dates
  # TODO benchmark against doing this in raw SQL
  # @return Active Record collection
  def scheduled_projects(start_date, end_date)
    suitable_entries = Entry.for_user_period(self.id, start_date, end_date)
    Project.find(suitable_entries.map(&:project_id))
  end
  
  # Public: Returns Scheduled projects between two dates as an ICS file
  #
  # start_date = Date to filter from
  # end_date   = Date to filter to
  #
  # Returns an Icalendar::Calendar
  def scheduled_projects_ics(start_date = Date.today, end_date = 8.days.from_now)
    calendar = Icalendar::Calendar.new
    selected_entries_started = entries.where(start_date: start_date.to_date...end_date.to_date).all
    selected_entries_ended = entries.where(end_date: start_date.to_date...end_date.to_date).all
    selected_entries_started.concat(selected_entries_ended).uniq.each do |entry|
      calendar.add_event(entry.to_ics)
    end
    calendar
  end


  # Search users by first or last name
  def self.search_users(account, params)
    a_conditions = []
    a_conditions << ["users.account_id = ?", account.id]
    a_conditions << ["users.firstname LIKE ?", params[:firstname] + '%'] if params[:firstname].present?
    a_conditions << ["users.lastname LIKE ?", params[:lastname] + '%'] if params[:lastname].present?
    
    # Archived
    if params[:archived] == '0'
      a_conditions << ["users.archived = ?", false]
    elsif params[:archived] == '1'
      a_conditions << ["users.archived = ?", true]
    end

    User.where([a_conditions.transpose.first.join(' AND '),*a_conditions.transpose.last])
        .paginate(:page => params[:page],
                  :per_page => APP_CONFIG['pagination']['site_pagination_per_page'])
        .order('users.firstname, users.lastname')
  end


  # Set the email address and downcase
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end


  # Set the last time a user logged in to now
  def set_last_login
    self.update_attributes(:last_login_at => Time.now.utc)
  end


  # Assign account holder rights to a user
  def make_account_holder(save_after = true)
    self.roles << Role.find_by_title('account_holder')
    self.save if save_after
  end


  # create a password reset code and save to db
  def make_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    self.save
  end


  # Remove any password reset code that may be saved in the db
  def clear_reset_code
    self.password_reset_code = nil
    self.save
  end


  # Returns the days worked for a user
  #
  # Returns a hash in the form :day => boolean
  def days_worked
    days = account.account_setting.working_days
    Hash[days.map { |k,v| [k, (v == "1")] }]
  end


  # Does a user work on a given day?
  #
  # - day a string or symbol i.e :sunday
  #
  # Returns a Boolean
  def works_on? day
    days_worked[day.to_sym]
  end


  # Returns all the days in a date range that a user is scheduled to work
  #
  # - user_id     Integer
  # - start_date  Date
  # - end_date    Date
  #
  # Returns an array of dates
  def days_scheduled(start_date, end_date)
    all_entries = Entry.user_entries_by_date(self.id, start_date, end_date)
    all_entries.select { |_,v| v.any? }.keys
  end


  # The number of days that a user is scheduled to work in a given date range
  #
  # - user_id     Integer
  # - start_date  Date
  # - end_date    Date
  #
  # Returns an Integer
  def number_of_days_scheduled(start_date, end_date)
    days_scheduled(start_date, end_date).count
  end


  # Returns the number of days a user is expected to work for a date range
  #
  # - start_date  date
  # - end_date    date
  #
  # Returns an Integer
  def potential_working_days(start_date, end_date)
    days_worked = (start_date..end_date).select do |day|
      day = day.strftime("%A").downcase.to_sym
      works_on?(day)
    end
    days_worked.count
  end


  # Returns the users capacity. This is a measure of how much work has been scheduled
  # vs the possible time a user could be potentially scheduled for
  #
  #
  # Returns an Integer
  def capacity(start_date, end_date)
    potential_days = potential_working_days(start_date, end_date)
    actual_days = number_of_days_scheduled(start_date, end_date)
    actual_capacity = (100 / potential_days.to_f) * actual_days
    actual_capacity.to_i
  end


  #
  # Used to update admin users in tool
  def self.update_administrators(account, selected_user_ids=[], current_user)
    # Remove admins that are no longer required
    account.users.each do |user|
      if user.is_administrator? && user.id != current_user.id
        unless selected_user_ids.include?(user.id.to_s)
          user.roles = []
          user.save!
        end
      end
    end

    # New admins
    administrator_role = Role.find_by_title('administrator')
    selected_user_ids.each do |user_id|
      user = account.users.find(user_id)

      # Dont update account holders, people who are already admins or current users
      # e.g. if !user.is_account_holder? && !user.is_administrator? && user.id != current_user.id
      if user.roles.blank? && user.id != current_user.id
        user.roles << administrator_role
      end
    end
    true # why do we need to return this value?
  end

  # Public: Get estimated amount of billable money for a User
  #
  # start_date - The date to start filtering from
  # end_date   - Date to stop filtering from
  #
  # Returns an Integer
  def billable_amount_cents(start_date = 1.month.ago, end_date = Date.today)
    user_total = 0
    user_timings = timings.submitted_timings.where(started_at: start_date...end_date)
                                            .joins(:project)
                                            .group(:client_id)
    user_timings.each do |timing_group|
      if timing_group.project.client.present?
        user_total += timing_group.project.client.avg_rate_card_amount_cents * (user_timings.map(&:duration_minutes).sum.to_s.to_d / account.account_setting.working_day_duration_minutes)
      end
    end
    user_total
  end

  # Public: Get User utilisation as a percentage to 2 decimal places
  #
  # Returns a Decimal
  def utilisation(start_date = 1.month.ago, end_date = Date.today)
    all_timings = timings.submitted_timings.where(started_at: start_date...end_date)
                                           .joins(:task)

    external_tracked_time = all_timings.where(tasks:   { count_towards_time_worked: true })
                                       .where(clients: { internal: false })
                                       .joins(project: :client)
                                       .sum(&:duration_minutes)
                                       .to_f

    total_tracked_time = all_timings.sum(&:duration_minutes).to_f

    ((external_tracked_time / total_tracked_time) * 100.0).round(2)
  end

  # Public: Get list of User's working days without time tracked
  #
  # look_back - Amount of time to look back in time for days 
  # without time tracked. Default: 1 week
  #
  # Returns an Array of Dates. This is empty if the User has an up
  # to date timesheet.
  # Returns an empty Array if the User is archived.
  def days_without_time_tracked(look_back = 1.week)
    raise ArgumentError, 'look_back must be at least 1 day' if look_back < 1.day
    return [] if archived?
    results = []
    dates = (look_back.ago.to_date..Date.today - 1).map(&:to_date).reject{ |d| d.saturday? || d.sunday? }
    dates.each do |date|
      results << date if timings.submitted_timings.where(started_at: date.beginning_of_day...date.end_of_day).blank?
    end
    results
  end

#
# Chargify
#


  #
  # Update chargify if user is the account holder
  def update_user_details_in_chargify
    unless self.account.chargify_customer_id.blank?

      if self.roles.any? { |r| r.title == 'account_holder' }
        chargify_customer = Chargify::Customer.find_by_reference(self.account.id)
        chargify_customer.first_name = self.firstname
        chargify_customer.last_name = self.lastname
        chargify_customer.email = self.email
        chargify_customer.save
      end
    end
  end


  # Used to pass over url to json requests
  def user_calendar_image
    url = self.gravatar_url(:size => 40,
                      :default => 404)

    response = HTTParty.get(url)
    response.code == 404 ? 404 : url
  end


  # Returns the projects currently being tracked by a user (within the last month)
  #
  # Used in the Track API to find projects relevant to a user
  #
  def projects_tracked
    timings = Timing.for_period_of_time(self.id, 1.month.ago, Time.now)
    if timings.present?
      timings.map(&:project_id).uniq
    else
      []
    end
  end

  # Public: Make sure that when a user's role is updated
  # that the associated Account still has an account holder.
  # Otherwise, fail validation.
  def check_account_holder_exists
    valid = false
    if account.present?
      account.users.each do |user|
        if (user.roles.map(&:title) & ['account_holder']).present?
          valid = true
        end
      end
      unless valid
        errors.add(:roles, 'cannot delete the only account holder')
      end
    end
  end

  def parsed_biography
    biography(true)
  end

  def biography(parsed = false)
    if read_attribute(:biography).present?
      parsed ? RDiscount.new(read_attribute(:biography), :filter_styles, :filter_html, :autolink, :smart).to_html : read_attribute(:biography)
    else
      ''
    end

    
  end

  # Access token and API keys
  # *****************************************

  # Create a new API key for a user
  #
  def assign_api_key!
    self.api_key = ApiKey.create!
  end

  # Returns a users access token
  #
  # Returns a String
  def access_token
    api_key.access_token rescue ""
  end

  # Reset a users API token (and delete the old one)
  #
  def reset_token!
    api_key.delete if api_key.present?
    assign_api_key!
  end

  # Finds a user with a given API token, else return nil
  #
  # - token String
  #
  def self.find_by_api_token(token)
    User.find_by_sql(["""select u.* from users u
                        inner join api_keys a on u.id = a.user_id
                        and a.access_token = ?""", token]).first
  end
end
