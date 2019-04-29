class Timing < ActiveRecord::Base

  # External libs

  # Relationships
  belongs_to :user
  belongs_to :project, touch: true
  belongs_to :task


  # Validation
  validates :user_id, :project_id, :presence => true
  validates :task_id, :presence => { :if => :submitted? }
  validates :started_at, :ended_at, :presence => true
  validates :notes, :length => { :maximum => 1000 }
  validate  :start_is_before_end
  validate  :start_and_end_on_same_day
  validate  :does_not_have_other_timing_for_given_period
  validate  :check_associated


  # Callbacks
  before_save   :calc_duration
  before_create :submit_if_others_for_day_are_submitted
  after_update  :check_within_estimate

  # Mass assignment protection
  attr_accessible :started_at, :ended_at, :project_id, :task_id, :notes, :submitted


  # Named scopes
  scope :submitted_timings, where(['timings.submitted = ?', true])
  scope :date_ordered, order('timings.started_at')


  def started_at_utc
    Time.utc(read_attribute(:started_at).to_s)
  end


  def ended_at_utc
    Time.utc(read_attribute(:started_at).to_s)
  end


  #
  # Find the timings within a given date range (pass in date object)
  def self.for_period(user_id, start_date, end_date, include_project = false)
    timings = Timing.where(['timings.user_id = ? AND timings.started_at <= ? AND timings.ended_at >= ?', user_id, end_date.end_of_day, start_date.to_datetime]).order('timings.started_at')
    if include_project
      timings = timings.includes([:project])
    end
    timings
  end


  # TODO test
  # Find the submitted timings within a given date range (pass in date object)
  def self.submitted_for_period(user_id, start_date, end_date, include_project = false)
    timings = Timing.where(['timings.user_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', user_id, end_date.end_of_day, start_date.to_datetime, true]).order('timings.started_at')
    if include_project
      timings = timings.includes([:project])
    end
    timings
  end


  # Find the timings within a given date range (pass in time object)
  def self.for_period_of_time(user_id, start_time, end_time)
    Timing.where(['timings.user_id = ? AND timings.started_at <= ? AND timings.ended_at >= ?', user_id, end_time, start_time]).order('timings.started_at')
  end


  # Find the timings within a given date range
  def self.submitted_for_period?(user_id, start_date, end_date)
    timings = Timing.where(['timings.user_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', user_id, end_date.end_of_day, start_date.to_datetime, true]).count
    if timings == 0
      false
    else
      true
    end
  end


  def self.for_period_and_team(team_id, start_date, end_date)
    Timing.where(['teams.id = ? AND timings.started_at <= ? AND timings.ended_at >= ?', team_id, end_date.end_of_day, start_date.to_datetime]).includes({:user => :teams}).order('timings.started_at')
  end
  
  
  # Find all timings between a given date range (pass in date object) for a given project (submitted time only).
  def self.submitted_for_period_by_project(project_id, start_date, end_date)
    Timing.where(['timings.project_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', project_id, end_date.end_of_day, start_date.to_datetime, true]).order('timings.started_at')
  end
  
  
  # Duration between a given date range (pass in date object) for a given project (submitted time only).
  def self.minute_duration_submitted_for_period_by_project(project_id, start_date, end_date)
    timings = Timing.submitted_for_period_by_project(project_id, start_date, end_date)
    timings.sum(:duration_minutes)
  end
  
  
  def self.minute_duration_submitted_for_period_and_client(client_id, start_date, end_date)
    Timing.where(['projects.client_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', client_id, end_date.end_of_day, start_date.to_datetime, true]).includes(:project).sum(:duration_minutes)
  end
  
  
  def self.minute_duration_submitted_for_client(client_id)
    Timing.where(['projects.client_id = ? AND timings.submitted = ?', client_id, true]).includes(:project).sum(:duration_minutes)
  end
  

  # Duration in minutes of the total submitted time for a given team between a date range
  def self.minute_duration_submitted_for_period_and_team(team_id, start_date, end_date)
    Timing.where(['team_users.team_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', team_id, end_date.end_of_day, start_date.to_datetime, true]).includes({:user => :team_users}).sum(:duration_minutes)
  end
  
  
  # Duration in minutes of the total submitted time for a given team and project between a date range
  def self.minute_duration_submitted_for_period_and_team_and_project(team_id, project_id, start_date, end_date)
    Timing.where(['team_users.team_id = ? AND timings.project_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', team_id, project_id, end_date.end_of_day, start_date.to_datetime, true]).includes({:user => :team_users}).sum(:duration_minutes)
  end
  

  # Find timings for a given user or team
  def self.search(account, cal, params)
    if params[:user_id].present?
      user = account.users.find(params[:user_id])
      Timing.for_period(user.id, cal.start_date, cal.end_date)
    elsif params[:team_id].present?
      team = account.teams.find(params[:team_id])
      Timing.for_period_and_team(team.id, cal.start_date, cal.end_date)
    else
      []
    end
  end


  # Find the users that have tracked to a given project
  def self.users_for_project(project_id)
    User.includes([:timings]).group('users.id').order('users.firstname').where(['timings.project_id = ? AND timings.submitted = ?', project_id, true])
  end
  

  def self.users_for_project_in_period(project_id, start_date, end_date)
    User.includes([:timings]).group('users.id').order('users.firstname').where(['timings.project_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', project_id, end_date.end_of_day, start_date.to_datetime, true])
  end


  def self.users_for_client_in_period(client_id, start_date, end_date)
    User.includes([{:timings => :project}]).group('users.id').order('users.firstname').where(['projects.client_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', client_id, end_date.end_of_day, start_date.to_datetime, true])
  end
  
  
  # Get all the projects for a given client that have had time tracked to them between the given date range
  def self.projects_for_client_in_period(client_id, start_date, end_date)
    Project.includes([:timings]).group('projects.id').order('projects.name').where(['projects.client_id = ? AND timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?', client_id, end_date.end_of_day, start_date.to_datetime, true])
  end


  # Find the users that have tracked to a given project
  def self.users_for_client(client_id)
    User.includes([{:timings => :project}]).group('users.id').order('users.firstname').where(['projects.client_id = ? AND timings.submitted = ?', client_id, true])
  end


#
# Graph extract functions
#


  # TODO test
  # Extract and format data ready to be used in presenting data in a chart or graph
  def self.time_tracked_group_by_task_and_user(project)
    return nil if project.tasks.blank?
    timings = project.timings.submitted_timings
    h_tasks = {}
    h_users = {}

    # Get all users
    if timings.present?
      timings.each do |timing|
        if timing.task_id.present?
          h_users[timing.user_id] = {:name => timing.user.name, :tracked_minutes => 0, :tracked_duration_in_hours =>'0 mins'} unless h_users.has_key?(timing.user_id)
        end
      end
    end


    # Create task has
    project.tasks.name_ordered.each do |task|
      # Set it to always out put data in mins
      task.estimate_scale = 0
      estimate_hours = task.estimated_minutes / 60
      estimate_minutes = task.estimated_minutes % 60
      # Marshal.load(Marshal.dump(h_users)) performs a deep clone
      h_tasks[task.id] = {:name => task.name, :estimate_minutes => task.estimated_minutes, :estimate_duration_in_hours => "#{ estimate_hours } hours #{ estimate_minutes } minutes", :users => Marshal.load(Marshal.dump(h_users))}
    end


    # Add timings
    if timings.present?
      timings.each do |timing|
        if timing.task_id.present?
          h_tasks[timing.task_id][:users][timing.user_id][:tracked_minutes] += timing.duration_minutes

          tracked_duration_in_hour = (h_tasks[timing.task_id][:users][timing.user_id][:tracked_minutes] / 60).to_i
          tracked_duration_in_min = h_tasks[timing.task_id][:users][timing.user_id][:tracked_minutes]% 60


          h_tasks[timing.task_id][:users][timing.user_id][:tracked_duration_in_hours] = "#{tracked_duration_in_hour} "+ (tracked_duration_in_hour == 1 ? 'hour' : 'hours') +" #{tracked_duration_in_min} mins"
        end
      end

    end

    return h_users, h_tasks
  end

#
# Save functions
#


  #
  # Submits the given date / user
  def self.submit_entries_for_user_and_day(user_id, date)
    timings = Timing.where(['timings.user_id = ? AND timings.started_at <= ? AND timings.ended_at >= ?', user_id, date.end_of_day, date.to_datetime])
    if timings.count > 0
      for timing in timings
        return 1 if timing.task_id.blank?
      end
      timings.each { |t| t.update_attributes(submitted: true) }
      return 0
    else
      return 2
    end
  end

  protected


  # Work out the duration based on the start - end time
  def calc_duration
    self.duration_minutes = ((self.ended_at - self.started_at) / 60) + 1
  end


  # Submit time entry if others on that given day have already been submitted
  def submit_if_others_for_day_are_submitted
    if self.user_id.present?
      submitted = Timing.submitted_for_period?(self.user_id, self.started_at.to_date, self.ended_at.to_date)
      self.submitted = true if submitted
    end
  end


  # Check that the start time is before the end
  def start_is_before_end
    if self.started_at.present? && self.ended_at.present?
		  errors.add(:started_at, "can't be before the start time") if self.ended_at < self.started_at
    end
  end


  #
  # Check that it starts and ends on the same day
  def start_and_end_on_same_day
    if self.started_at.present? && self.ended_at.present?
      errors.add(:started_at, "must be the same day as the end time.") if self.started_at.to_date != self.ended_at.to_date
    end
  end


  #
  # Check that there is no other entries for the given period
  def does_not_have_other_timing_for_given_period
    if self.started_at.present? && self.ended_at.present? && self.user_id.present?
      timings = Timing.for_period_of_time(self.user_id, self.started_at, self.ended_at)

      if timings.present?
        if self.new_record?
          errors.add(:started_at, "and ended at must not overlap an existing entry")
        else
          # check its a different id if not a new record
          timings = timings.reject {|t| t.id == self.id}
          errors.add(:started_at, "and ended at must not overlap an existing entry") if timings.present?
        end
      end
    end
  end


  # Check to see that the given forign keys all belong to the same account
  def check_associated
    if self.user_id.present?
      account = self.user.account

      if self.project_id.present?
        errors.add(:project_id, "does not exist") unless account.projects.exists?(self.project_id)
      end

      if self.task_id.present?
        if account.projects.exists?(self.project_id)
          project = account.projects.find(self.project_id)
          errors.add(:task_id, "does not exist") unless project.tasks.exists?(self.task_id)
        end
      end
    end
  end

  # Internal: Sends email if timing causes overestimate
  def check_within_estimate
    duration = Timing.where(task_id: task_id).where(submitted: true).sum(:duration_minutes)
    if duration > task.estimated_minutes && (duration - duration_minutes) <= task.estimated_minutes
      ProjectMailer.overrun_task(task).deliver
    end
  end

end
