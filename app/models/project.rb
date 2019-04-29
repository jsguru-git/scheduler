class Project < ActiveRecord::Base


  # External libs
  include SharedMethods
  include ProjectBurndown


  # Relationships
  belongs_to :account
  belongs_to :client
  belongs_to :team
  belongs_to :business_owner, :class_name => "User", :foreign_key => "business_owner_id"
  belongs_to :project_manager, :class_name => "User", :foreign_key => "project_manager_id"
  belongs_to :phase

  has_many   :entries, :dependent => :destroy
  has_many   :tasks, :dependent => :nullify
  has_many   :features, :dependent => :destroy
  has_many   :timings, :dependent => :restrict
  has_one    :account_setting, :foreign_key  => 'common_project_id'
  has_many   :payment_profiles, :dependent => :destroy
  has_many   :invoices, :dependent => :destroy
  has_many   :invoice_deletions, :dependent => :nullify
  has_many   :quotes, :dependent => :destroy
  has_many   :documents, :dependent => :destroy
  has_many   :project_comments, :dependent => :destroy
  has_many   :payment_profile_rollovers, :dependent => :nullify
  has_many   :qa_stats, dependent: :destroy
  


  # Validation
  validates :account_id, :presence => true
  validates :name, :event_type, :presence => true, :length => { :maximum => 255 }
  validates :color, :presence => true, :length => { :maximum => 7 }, :hex_color => true
  validates_uniqueness_of :name,
                          :case_sensitive => false,
                          :message => "already exists",
                          :scope => [:account_id]

  validates_uniqueness_of :project_code,
                          case_sensitive: false,
                          allow_blank: true,
                          allow_nil: true,
                          scope: :account_id

  validates :description, :length => { :maximum => 2000 }
  validate  :relations_must_belong_to_same_account
  validates :current_rag_status, :expected_rag_status, :inclusion => { :in => SELECTIONS['rag_status'].keys }
  validates :percentage_complete, :numericality => {:only_integer => true, :greater_than => -1, :less_than => 101}, :allow_blank => true, :presence => true
  validate :issue_track_project_id_exists
  

  # Callbacks
  before_validation :remove_whitespace
  before_validation :update_status, :unless => Proc.new { |p| p.project_status_overridden? }
  after_touch       :touch_status, :unless => Proc.new { |p| p.project_status_overridden? }

  
  # Virtual attributes
  attr_accessor :validate_issue_tracker_id


  # Mass assignment protection
  attr_accessible :name, :description, :archived, :team_id, :client_id, :color, :event_type, :project_code, :team_id, :business_owner_id, :project_manager_id, :current_rag_status, :expected_rag_status, :project_status, :project_status_overridden, :percentage_complete, :issue_tracker_id, :phase_id


#
# Extract methods
#


  # Named scopes
  scope :name_ordered, order('projects.name')
  scope :not_archived, where(["archived = ?", false])
  scope :stale_opportunities, where(project_status: :opportunity).where('updated_at < ?', 2.weeks.ago)
  scope :not_closed, where(["projects.project_status != ?", 'Closed'])
  
  STATUSES = {
    :opportunity => 'Opportunity',
    :approved => 'Approved',
    :scheduled => 'Scheduled',
    :in_progress => 'In Progress',
    :closed => 'Closed'
  }


  # Search projects
  def self.search(account, params)
    a_conditions = []
    a_conditions << ["projects.account_id = ?", account.id]

    # project name
    a_conditions << ["projects.name LIKE ?", params[:name] + '%'] if params[:name].present?

    # client
    a_conditions << ["projects.client_id = ?", params[:client_id]]   if params[:client_id].present?

    if params[:status].present? && params[:status].eql?('open')
      a_conditions << ["projects.project_status != ?", :closed]
    elsif params[:status].present?
      a_conditions << ["projects.project_status = ?", params[:status]]
    end

    if params[:format] == 'json'
      results = Project.where([a_conditions.transpose.first.join(' AND '),
                     *a_conditions.transpose.last]).order('projects.name')
    else
      results = Project.where([a_conditions.transpose.first.join(' AND '),
                     *a_conditions.transpose.last]).includes([:client])
             .paginate(:page => params[:page],
                       :per_page => APP_CONFIG['pagination']['site_pagination_per_page'])
             .order('projects.name')
    end
  end


  # Find all users who are scheduled from the given date
  def people_scheduled_for_next_week_from(start_date)
    end_date = start_date + 6.days
    Entry.users_for_project_in_period(self.id, start_date, end_date)
  end


  # Find all users that have sumitted tracked time from a fiven date
  def people_tracked_for_a_week_from(start_date)
    end_date = start_date + 6.days
    Timing.users_for_project_in_period(self.id, start_date, end_date)
  end


  # Get all people who have been scheudled to the proejct
  def all_people_scheduled
    Entry.users_for_project(self.id)
  end

  
  # Get all people who have tracked time to the project
  def all_people_tracked
    Timing.users_for_project(self.id)
  end

  
  # Get the date that the project is due to start according to the schedule
  def schedule_start_date
    entry = self.entries.order('entries.start_date').first
    if entry.present?
      entry.start_date
    else
      nil
    end
  end


  # Get the time estimate for the project from the tasks
  def total_estimate
    self.tasks.sum(:estimated_minutes)
  end


  # Get the total amount of time that has been tracked
  def total_tracked
    self.timings.submitted_timings.sum(:duration_minutes)
  end

  # Public: When a Project is expected to end
  #
  # Returns a Date or nil
  def estimated_end_date
    return nil unless timings.submitted_timings.any? && percentage_complete.between?(1, 99)

    date_range = Date.today - timings.submitted_timings.date_ordered.first.started_at.to_date
    days_predicted = (date_range.to_f / (percentage_complete.to_f / 100)).round
    difference = days_predicted - date_range
    difference.days.from_now.to_date
  end
  
  # Project costs
  def total_project_cost_cents
    self.payment_profiles.sum(:expected_cost_cents)
  end
  
  
  # Project cost which has not yet been invoiced
  def total_project_cost_cents_not_invoiced
    profiles = self.payment_profiles.includes(:invoice_item).select { |p| p.invoice_item.blank? }
    profiles.sum(&:expected_cost_cents)
  end
  
  
  # Project cost which has been invoiced
  def total_project_cost_cents_invoiced
    profiles = self.payment_profiles.includes(:invoice_item).select { |p| p.invoice_item.present? }
    profiles.sum(&:expected_cost_cents)
  end


  # Check if a project has any tasks associated with it
  def has_tasks?
    self.tasks.present?
  end
  
  
  # Get projects which are expecting a payment this month
  def self.number_with_payment_expected_for_period(account, start_date, end_date)
    Project.includes([:payment_profiles])
      .where(["projects.account_id = ? AND (payment_profiles.expected_payment_date >= ? AND payment_profiles.expected_payment_date <= ?)", account.id, start_date, end_date])
      .count
  end
  
  
  # Get projects which are expecting a payment this month
  def self.number_with_payment_expected_for_period_with_raised_invoice(account, start_date, end_date)
    Project.includes([{:payment_profiles => :invoice_item}])
      .where(["projects.account_id = ? AND payment_profiles.expected_payment_date >= ? AND payment_profiles.expected_payment_date <= ? AND invoice_items.id IS NOT ?", account.id, start_date, end_date, nil])
      .count
  end
  
  
  # Extract results for the payments predications report
  def self.payment_prediction_results(account, params, start_date, end_date)
    sql = "SELECT DISTINCT(projects.id), projects.name AS project_name, clients.name AS client_name, teams.name AS team_name, CONCAT_WS(' ', users.firstname, users.lastname) AS account_owner, MAX(invoices.pre_payment) AS pre_payment, projects.project_status AS project_status,
         sum(case when invoice_items.id IS NULL 
         then 
          payment_profiles.expected_cost_cents 
         else 
          (invoice_items.default_currency_amount_cents * invoice_items.quantity) 
         end) AS amount_cents, 
         case when invoice_items.id IS NULL 
          then 
           'expected' 
          else 
            case when invoices.invoice_status = 0 
             then 
              'requested' 
             else 
              'sent' 
             end
          end AS status,
         payment_profiles.expected_payment_date AS expected_payment_date
         FROM projects 
         LEFT OUTER JOIN payment_profiles ON payment_profiles.project_id = projects.id 
         LEFT OUTER JOIN invoice_items ON invoice_items.payment_profile_id = payment_profiles.id 
         LEFT OUTER JOIN invoices ON invoices.id = invoice_items.invoice_id 
         LEFT OUTER JOIN clients ON clients.id = projects.client_id 
         LEFT OUTER JOIN teams ON teams.id = projects.team_id
         LEFT OUTER JOIN users ON users.id = projects.business_owner_id
         WHERE projects.account_id = ?
         AND (payment_profiles.expected_payment_date >= ? AND payment_profiles.expected_payment_date <= ?)"
         sql += " AND projects.team_id = ?" if params[:team_id].present?
         sql += " GROUP BY projects.id, status 
         ORDER BY clients.name, projects.name, projects.id"
     
     sql_array = [sql, account.id, start_date, end_date]
     sql_array << params[:team_id] if params[:team_id].present?
     results = Project.find_by_sql(sql_array)
     
     projects = {}
     results.each do |result|
       unless projects.has_key?(result.id)
         projects[result.id] = {:id => result.id, :project_name => result.project_name, :team_name => result.team_name, :client_name => result.client_name, :expected => 0, :requested => 0, :sent => 0, :expected_incl_pre_payment => false, :requested_incl_pre_payment => false, :sent_incl_pre_payment => false, :account_owner => result.account_owner, :project_status => result.project_status, :expected_payment_date => result.expected_payment_date }
       end
       
       projects[result.id][result.status.to_sym] += result.amount_cents.to_i
       projects[result.id]["#{result.status}_incl_pre_payment".to_sym] = true if result.pre_payment?
     end
     
     projects
  end
  
  
  # Payment preduction totals
  def self.payment_prediction_totals(account, params, start_date, end_date)
    given_month_totals = Project.prediction_total_sql(account, params, start_date, end_date)
    last_years_totals = Project.prediction_total_sql(account, params, (start_date - 1.year), (end_date - 1.year))
    total_pre_paid = Project.prediction_total_pre_paid_sql(account, params, start_date, end_date)
    
    details = {:current_year => {:expected => 0, :requested => 0, :sent => 0, :total => 0, :pre_payment_total => 0}, :last_year => {:expected => 0, :requested => 0, :sent => 0, :total => 0}}
    given_month_totals.each do |result|
      details[:current_year][result.status.to_sym] = result.amount_cents.to_i
    end
    details[:current_year][:total] = details[:current_year][:expected ] + details[:current_year][:requested] + details[:current_year][:sent]
    
    last_years_totals.each do |result|
      details[:last_year][result.status.to_sym] = result.amount_cents.to_i
    end
    details[:last_year][:total] = details[:last_year][:expected ] + details[:last_year][:requested] + details[:last_year][:sent]

    details[:current_year][:pre_payment_total] = total_pre_paid.first.amount_cents.to_i if total_pre_paid.first.present?
    
    details
  end


#
# Save methods
#


  #
  # Create the default internal projects when an account is created
  def self.create_default_internal_projects(account)
    project = account.projects.create!(:event_type => 1,
                                       :name => 'Common tasks',
                                       :color => '#A9BFD7')
    project.tasks.create!(:name => 'General Admin')
    project.tasks.create!(:name => 'Lunch', :count_towards_time_worked => false)
    project.tasks.create!(:name => 'Annual leave')
    project.tasks.create!(:name => 'Flexi leave', :count_towards_time_worked => false)
    project.tasks.create!(:name => 'Internal Meeting')

    account.account_setting.common_project_id = project.id
    account.account_setting.save!
  end


  # Archive the project
  def archive_now
    self.update_attributes(:archived => true)
  end

  
  # Un archive the project
  def un_archive_now
    self.update_attributes(:archived => false)
  end
  
  # Public: Converts database value into a human readable String
  #
  # Returns a String
  def project_status_name
    STATUSES[read_attribute(:project_status).to_sym]
  end

  # Public: Overrides the automated Project status
  #
  # status - String of new status
  #
  # Returns the updated Project
  def override_status(status)
    update_attributes({ project_status: status, project_status_overridden: true })
  end

  def closed?
    paid_payment_profiles = invoices.where(invoice_status: 2).all.collect { |i| i.invoice_items.collect { |ii| ii.payment_profile }}.flatten
    paid_payment_profiles.size > 0 && payment_profiles.size == paid_payment_profiles.size && timings.any? && timings.last.ended_at < 2.weeks.ago
  end

  # Public: Gets the expected amount a project should have invoiced for a particular period
  # of time based on recorded timings.
  #
  # start_date - Time to filter from
  # end_date   - Time to filter to
  #
  # Returns a Hash
  def expected_invoice_amount_cents_for_period(start_date, end_date, user_id = nil)
    result = 0
    result_timings = timings.includes(:project).submitted_timings.where(started_at: start_date...end_date)
    result_timings = result_timings.where(user_id: user_id) if user_id.present?
    result_timings.each do |timing|
      per_minute_amount = timing.project.client.avg_rate_card_amount_cents / account.account_setting.working_day_duration_minutes
      result += (per_minute_amount * timing.duration_minutes)
    end
    result
  end
  
  
  # Public: Send project budget emails
  def self.send_project_budget_email
    # Find in batches
    Project.where(["projects.project_status != ?", STATUSES[:closed]]).find_each do |project|
      
      # Check has time tracked and has an estimate
      if project.total_tracked > 0 && project.total_estimate > 0
        new_percentage = ((project.total_tracked / project.total_estimate.to_f) * 100)
        
        # Only do if we have someone to send the email to
        if project.project_manager.present? || project.account.account_setting.budget_warning_email.present?
          if project.last_budget_check < 100.0 && new_percentage >= 100.0
            ProjectMailer.project_budget_email(project, project.account.account_setting, '100').deliver
          elsif project.last_budget_check < 75.0 && new_percentage >= 75.0
            ProjectMailer.project_budget_email(project, project.account.account_setting, '75').deliver
          elsif project.last_budget_check < 50.0 && new_percentage >= 50.0
            ProjectMailer.project_budget_email(project, project.account.account_setting, '50').deliver
          elsif project.last_budget_check < 25.0 && new_percentage >= 25.0
            ProjectMailer.project_budget_email(project, project.account.account_setting, '25').deliver
          end
        end
        
        project.last_budget_check = new_percentage
        project.save(:validate => false)
      end
    end
  end

  # Public: Time estimate based on Quotes
  #
  # Returns an Integer for estimated time in minutes
  def total_quote_estimate
    total_estimate_minutes = 0

    quotes.each do |quote|
      quote_costs = quote.quote_activities.collect { |a| a.min_estimated_minutes }
      total_estimate_minutes += quote_costs.sum
    end

    total_estimate_minutes
  end

  # Public: Time estimate based on PaymentProfiles
  #
  # Returns an Integer for estimated time in minutes
  def total_payment_profiles_estimate
    total_estimate_minutes = payment_profiles.collect { |p| p.expected_minutes }.compact.sum
  end

  # Public: Convert data to burndown by week
  #
  # graph - Data to compare timings against
  #
  # Returns a Hash of weekly timings
  def burndown_chart(graph, opts = {})
    case graph.to_sym
    when :task
      task = tasks.find(opts[:task_id]) if opts[:task_id].present?
      if task.present?
        ProjectBurndown::burndown_chart_data(timings.where(task_id: task.id).submitted_timings.date_ordered, task.estimated_minutes)
      else
        ProjectBurndown::burndown_chart_data(timings.submitted_timings.date_ordered, total_estimate)
      end
    when :quote
      ProjectBurndown::burndown_chart_data(timings.submitted_timings.date_ordered, total_quote_estimate)
    when :payment_profile
      ProjectBurndown::burndown_chart_data(timings.submitted_timings.date_ordered, total_payment_profiles_estimate)
    end
  end

protected

  
  # Protected: Check that the issue tracker project id can be accessed using the api
  def issue_track_project_id_exists
    if self.issue_tracker_id.present? && self.validate_issue_tracker_id.present?
      issue_tracker = IssueTracker::JiraWrapper.new(self.account.account_setting)
      errors.add(:issue_tracker_id, "can not be found, please make sure it is correct and the FleetSuite Jira user has access to it") unless issue_tracker.project_exists?(self.issue_tracker_id)
    end
  end

  
  # Internal: Updates the project with appropriate status
  #
  # require_save - if save needs to be called on the model
  #
  # Returns project_status assigned with appropriate String
  def update_status(require_save = false)
    if closed?
      self.project_status = 'closed'
    elsif timings.any?
      self.project_status = 'in_progress'
    elsif entries.any?
      self.project_status = 'scheduled'
    elsif quotes.where(quote_status: 2).any?
      self.project_status = 'approved'
    else
      self.project_status = 'opportunity'
    end

    self.save if require_save
  end
  
  # Internal: Updates the project after association touch
  #
  # Returns project_status assigned with appropriate String
  def touch_status
    update_status(true)
  end

  
  # Check that all foreign keys being saved belong ot the same account as the project does
  def relations_must_belong_to_same_account
    if self.account_id.present?
      if self.client.present?
        errors.add(:client_id, "must belong to the same account") if self.account_id != self.client.account_id
      end
      
      if self.team.present?
        errors.add(:team_id, "must belong to the same account") if self.account_id != self.team.account_id
      end
      
      if self.business_owner.present?
        errors.add(:business_owner_id, "must belong to the same account") if self.account_id != self.business_owner.account_id
      end
      
      if self.project_manager.present?
        errors.add(:project_manager_id, "must belong to the same account") if self.account_id != self.project_manager.account_id
      end
    end
  end

  
  
  # Payment predictions sql
  def self.prediction_total_sql(account, params, start_date, end_date)
    sql = "SELECT sum(case when invoice_items.id IS NULL 
         then 
          payment_profiles.expected_cost_cents 
         else 
          (invoice_items.default_currency_amount_cents * invoice_items.quantity) 
         end) AS amount_cents, 
         case when invoice_items.id IS NULL 
          then 
           'expected' 
          else 
            case when invoices.invoice_status = 0 
             then 
              'requested' 
             else 
              'sent' 
             end
          end AS status 
         FROM projects 
         LEFT OUTER JOIN payment_profiles ON payment_profiles.project_id = projects.id 
         LEFT OUTER JOIN invoice_items ON invoice_items.payment_profile_id = payment_profiles.id 
         LEFT OUTER JOIN invoices ON invoices.id = invoice_items.invoice_id 
         LEFT OUTER JOIN clients ON clients.id = projects.client_id 
         WHERE projects.account_id = ?
         AND (payment_profiles.expected_payment_date >= ? AND payment_profiles.expected_payment_date <= ?)"
         sql += " AND projects.team_id = ?" if params[:team_id].present?
         sql += " GROUP BY status 
         ORDER BY clients.name, projects.name, projects.id"

    sql_array = [sql, account.id, start_date, end_date]
    sql_array << params[:team_id] if params[:team_id].present?
    Project.find_by_sql(sql_array)
  end
  
  
  # Payment predictions get total amount pre-paid
  def self.prediction_total_pre_paid_sql(account, params, start_date, end_date)
    sql = "SELECT sum((invoice_items.default_currency_amount_cents * invoice_items.quantity)) AS amount_cents
         FROM projects 
         LEFT OUTER JOIN payment_profiles ON payment_profiles.project_id = projects.id 
         LEFT OUTER JOIN invoice_items ON invoice_items.payment_profile_id = payment_profiles.id 
         LEFT OUTER JOIN invoices ON invoices.id = invoice_items.invoice_id 
         LEFT OUTER JOIN clients ON clients.id = projects.client_id 
         WHERE projects.account_id = ?
         AND (payment_profiles.expected_payment_date >= ? AND payment_profiles.expected_payment_date <= ?)
         AND invoices.pre_payment = ?"
         sql += " AND projects.team_id = ?" if params[:team_id].present?

    sql_array = [sql, account.id, start_date, end_date, true]
    sql_array << params[:team_id] if params[:team_id].present?
    Project.find_by_sql(sql_array)
  end
  
  
end
