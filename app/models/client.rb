class Client < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  has_many :projects, :dependent => :nullify
  belongs_to :account
  has_many :client_rate_cards, :dependent => :destroy


  # Validation
  validates :account_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 150 }
  validates_uniqueness_of :name, :case_sensitive => false, :message => "already exists", :scope => [:account_id]

  validates :zipcode, :phone, :email, :fax, :length => { :maximum => 255 }
  validates_format_of :email, :allow_blank => true, :message => 'is not a valid format', :with => /\A([A-z0-9\.\-_]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i


  # Callbacks
  before_validation :remove_whitespace


  # Mass assignment protection
  attr_accessible :name, :archived, :address, :zipcode, :phone, :email, :fax, :internal



#
# Extract functions
#


  # Named scopes
  scope :name_ordered, order('clients.name')
  scope :not_internal, where(internal: false)

  #
  # Search the clients for a given account
  def self.search(account, params)
    a_conditions = []
    a_conditions << ["clients.account_id = ?", account.id]

    # Archived
    if params[:archived].blank? || params[:archived] == '0'
        a_conditions << ["clients.archived = ?", false]
    elsif params[:archived] == '1'
        a_conditions << ["clients.archived = ?", true]
    end

    account.clients.where([a_conditions.transpose.first.join(' AND '),*a_conditions.transpose.last]).paginate(:page => params[:page], :per_page => APP_CONFIG['pagination']['site_pagination_per_page']).order('clients.name')
  end


  # Get all peiple who are scheuled for a clients projects
  def all_people_scheduled
    Entry.users_for_client(self.id)
  end


  # Get peiple who are scheuled for a the next week for a clients projects
  def people_scheduled_for_next_week_from(start_date)
    end_date = start_date + 6.days
    Entry.users_for_client_in_period(self.id, start_date, end_date)
  end


  # Find all users that have sumitted tracked time from a fiven date
  def people_tracked_for_a_week_from(start_date)
    end_date = start_date + 6.days
    Timing.users_for_client_in_period(self.id, start_date, end_date)
  end


  # Find all people who have tracked time to a client
  def all_people_tracked
    Timing.users_for_client(self.id)
  end
  
  
  # Work out the avg day rate per client
  def avg_rate_card_amount_cents
    all_rate_cards = {}
    
    # Extract all custom rate cards
    if self.client_rate_cards.present?
      self.client_rate_cards.each do |client_rate_card|
        all_rate_cards[client_rate_card.rate_card_id] = client_rate_card.daily_cost_cents
      end
    end
    
    # Add all core rate cards in if custom one doesnt exist
    cl_account = self.account
    if cl_account.rate_cards.present?
      cl_account.rate_cards.each do |rate_card|
        all_rate_cards[rate_card.id] = rate_card.daily_cost_cents unless all_rate_cards.has_key?(rate_card.id)
      end
    end
    
    # Work out avg
    if all_rate_cards.length > 0
      total = all_rate_cards.values.inject(0) {|a,b|a+b}
      (total.to_s.to_d / all_rate_cards.length).to_i
    else
      0
    end
  end

  # Public: Checks if the Client is internal
  #
  # Returns a Boolean
  def internal?
    internal
  end

  # Public: Calculates the profit account of the client
  #
  # Returns a Decimal to 2dp
  def profit(cal)
    day_rate = avg_rate_card_amount_cents.round(2)
    mins_tracked = Timing.minute_duration_submitted_for_period_and_client(id, cal.start_date, cal.end_date)
    invoiced_amount = Invoice.amount_cents_invoiced_for_period_and_client(id, cal.start_date, cal.end_date).round(2)
    days_tracked = (hours = mins_tracked.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)

    (invoiced_amount - (days_tracked * day_rate.to_s.to_d)).round(2)
  end

  # Public: Calculates the estimated profit account of the client
  #
  # Returns a Decimal to 2dp
  def estimated_profit
    day_rate = avg_rate_card_amount_cents.round(2)
    mins_tracked = Timing.minute_duration_submitted_for_client(id)
    days_tracked = (mins_tracked.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)

    task_estimate_mins = Task.total_estimated_minutes_for_client(id)
    task_estimate_days = (task_estimate_mins.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)

    ((task_estimate_days * day_rate.to_s.to_d) - (days_tracked * day_rate.to_s.to_d)).round(2)
  end

  # Public: Calculates the day after profit and losses
  #
  # Returns a Decimal to 2dp
  def profit_day_rate(cal)
    day_rate = avg_rate_card_amount_cents.round(2)
    mins_tracked = Timing.minute_duration_submitted_for_period_and_client(id, cal.start_date, cal.end_date)
    days_tracked = (hours = mins_tracked.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)
    invoiced_amount = Invoice.amount_cents_invoiced_for_period_and_client(id, cal.start_date, cal.end_date).round(2)
    total_project_potential = (days_tracked * avg_rate_card_amount_cents.round).round(2)

    if invoiced_amount == 0 && days_tracked != 0
      0
    elsif invoiced_amount != 0 && days_tracked == 0
      invoiced_amount
    elsif invoiced_amount == 0
      day_rate
    else
      ((invoiced_amount / total_project_potential) * day_rate).round(2)
    end
  end

  # Public: Calculates the day after estimated profit and losses
  #
  # Returns a Decimal to 2dp
  def estimated_profit_day_rate
    day_rate = avg_rate_card_amount_cents.round(2)
    mins_tracked = Timing.minute_duration_submitted_for_client(id)
    days_tracked = (mins_tracked.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)

    task_estimate_mins = Task.total_estimated_minutes_for_client(id)
    task_estimate_days = (task_estimate_mins.to_s.to_d / account.account_setting.working_day_duration_minutes).round(2)

    total_project_potential = (days_tracked * day_rate).round(2)

    if task_estimate_days == 0 && days_tracked != 0
      0
    elsif task_estimate_days != 0 && days_tracked == 0
      (task_estimate_days * day_rate.to_s.to_d).round(2)
    elsif task_estimate_days == 0
      day_rate
    else
      (((task_estimate_days * day_rate.to_s.to_d) / total_project_potential) * day_rate).round(2)
    end
  end


#
# Save functions
#


#
# Create functions
#


#
# Update functions
#

  
  # Archive a client
  def archive_now
    self.update_attributes(:archived => true)
  end

  
  # Un-archive a cleint
  def un_archive_now
    self.update_attributes(:archived => false)
  end


#
# General functions
#


  protected

end
