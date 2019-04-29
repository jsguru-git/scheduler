class Team < ActiveRecord::Base

  # External libs
  include SharedMethods


  # Relationships
  belongs_to :account
  has_many :team_users, :dependent => :destroy
  has_many :users, :through => :team_users
  
  has_many :projects, :dependent => :nullify
  has_many :timings, :through => :users
  has_many :entries, :through => :users

  # Validation
  validates :account_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 50 }
  validates_uniqueness_of :name, :case_sensitive => false, :message => "already exists", :scope => [:account_id]


  # Callbacks
  before_validation :remove_whitespace
  
  
  # Mass assignment protection
  attr_accessible  :name


  # Named scopes
  scope :name_ordered, order('teams.name')
  scope :has_users, where(['users.id IS NOT ?', nil]).includes([:users])


  # Checks to see if the current user is a member of the given team
  def can_user_access?(user)
    if user.is_account_holder_or_administrator? || self.is_user_tagged_to_team?(user)
      true
    else
      false
    end
  end


  # Checks to see if the user has been tagged to the project
  def is_user_tagged_to_team?(user)
    self.users.include? user
  end

  # Public: Gets total invoice amount for all invoices associated with a team
  #
  # start_date - Time to filter from
  # end_date   - Time to filter to
  #
  # Returns an Integer
  def total_invoice_amount(start_date, end_date)
    total = 0
    projects.each do |project|
      total += project.invoices.where(due_on_date: start_date...end_date).map(&:total_amount_inc_vat).sum
    end
    total
  end

  # Public: Gets the expected amount a team should have invoiced for a particular period
  # of time based on recorded timings.
  #
  # start_date - Time to filter from
  # end_date   - Time to filter to
  #
  # Returns a Hash
  def expected_invoice_amount_cents_for_period(start_date, end_date, user_id = nil)
    results = { expected_invoice_amount:            0,
                contains_timings_without_rate_card: false }
    result_timings = timings.where(started_at: start_date...end_date)
    result_timings = result_timings.where(user_id: user_id) if user_id.present?
    result_timings.each do |timing|
      if timing.task.quote_activity.present?
        per_minute_amount = timing.task.quote_activity.rate_card.daily_cost  / account.account_setting.working_day_duration_minutes
        results[:expected_invoice_amount] += (per_minute_amount * timing.duration_minutes)
      else
        results[:contains_timings_without_rate_card] = true
      end
    end
    results
  end


end
