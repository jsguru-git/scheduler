# TODO description of model
#
# Calendar entries
#
class Entry < ActiveRecord::Base

   # Relationships

  belongs_to :account
  belongs_to :project, touch: true
  belongs_to :user

  # Validation

  validates :account_id, :user_id, :presence => true
  validates :project_id, :presence => true,
                         :if => Proc.new { |project| project.project_name.blank? }
  validates :start_date, :end_date, :presence => true
  validate  :relations_must_belong_to_same_account
  validate  :end_date_must_not_be_less_than_start_date
  validate  :new_project_name_is_valid

  # Callbacks

  before_validation :set_end_date
  before_validation :set_project_up_from_name
  after_save        :email_schedule_change

  # Mass assignment protection

  attr_accessible :start_date, :end_date, :project_id, :user_id, :project_name

  # Virtual attribute

  attr_accessor :project_name

  # Named scopes

  scope :start_date_ordered, order('entries.start_date')
  scope :ending_in_the_future, where('entries.end_date >= ?', Time.zone.now.to_date)


  # Public: Create a bulk schedule
  #
  # params - Hash of options (start_date, end_date, project_id)
  # exclude_non_working_days - Boolean to determine if the bulk should exclude non working days
  #
  # Returns an Array of Entries
  def self.create_bulk(params = {}, working_days = {}, exclude_non_working_days = true)
    if exclude_non_working_days
      splitter = DaySplitter.new(working_days)
      ranges = splitter.working_day_ranges(Date.parse(params[:start_date]), Date.parse(params[:end_date]))
      entries = ranges.map { |r| create(start_date: r[:start_date], end_date: r[:end_date], project_id: params[:project_id], user_id: params[:user_id]) }

      return entries
    else
      entry = create(start_date: params[:start_date], end_date: params[:end_date], project_id: params[:project_id], user_id: params[:user_id])

      return [entry]
    end
  end

  # Find the entries within a given date range
  def self.for_period(account_id, calendar_start_date, calendar_end_date)
    Entry
      .where(['entries.account_id = ? AND entries.start_date <= ? AND entries.end_date >= ?',
               account_id, calendar_end_date, calendar_start_date])
      .includes([:project])
      .order('entries.start_date')
  end


  # Find the entries for a given user that fall within a given date range
  def self.for_user_period(user_id, calendar_start_date, calendar_end_date)
    Entry
      .where(['entries.user_id = ? AND entries.start_date <= ? AND entries.end_date >= ?',
               user_id, calendar_end_date, calendar_start_date])
      .order('entries.start_date')
  end


  # Find the entries for a given project that fall within a given date range
  def self.for_project_period(project_id, calendar_start_date, calendar_end_date)
    Entry
      .where(['entries.project_id = ? AND entries.start_date <= ? AND entries.end_date >= ?',
               project_id, calendar_end_date, calendar_start_date])
      .order('entries.start_date')
  end


  # Find the entries for a given project that fall within a given date range
  def self.users_for_project_in_period(project_id, calendar_start_date, calendar_end_date)
    User.includes([:entries])
      .group('users.id')
      .order('users.firstname')
      .where(['entries.project_id = ? AND entries.start_date <= ? AND entries.end_date >= ?',
               project_id, calendar_end_date, calendar_start_date])
  end


  # Find all users that are scheduled for a given project
  def self.users_for_project(project_id)
    User.includes([:entries])
      .group('users.id')
      .order('users.firstname')
      .where(['entries.project_id = ?', project_id])
  end


  # Given a string in the form "May 2013" return an array
  # which contains the month start date and month end date.
  #
  # - date a string in the format "May 2013"
  #
  # Returns an array containing two dates
  def self.date_range_for_month_and_year(date)
    start_date = DateTime.parse(date).beginning_of_month
    end_date   = start_date.end_of_month
    [start_date, end_date]
  end


  # TODO test
  #
  # Find the entries for a given project that fall within a given date range
  def self.users_for_client_in_period(client_id, calendar_start_date, calendar_end_date)
    User.includes([{:entries => :project}])
      .group('users.id')
      .order('users.firstname')
      .where(['projects.client_id = ? AND entries.start_date <= ? AND entries.end_date >= ?',
               client_id, calendar_end_date, calendar_start_date])
  end


  # TOOD test
  # Find all users that are scheudled for a given project
  def self.users_for_client(client_id)
    User.includes([{:entries => :project}])
        .group('users.id')
        .order('users.firstname')
        .where(['projects.client_id = ?', client_id])
  end


  # Returns all entries for a given date organised by day
  def self.user_entries_by_date(user_id, calendar_start_date, calendar_end_date)
    found_entries = Entry.for_user_period(user_id, calendar_start_date, calendar_end_date)
    days = {}
    calendar_start_date.upto(calendar_end_date) do |current_date|
      entries_for_day = []

      if found_entries.present?
        found_entries.each do |entry|
          range = entry.start_date..entry.end_date
          entries_for_day << entry if range === current_date
        end
      end

      days[current_date] = entries_for_day
    end

    days
  end


  # Find the next entry for or after today for a given user
  def self.next_entry_for_user(user)
    user.entries.where(["entries.start_date >= ?", Date.today])
                .order('entries.start_date')
                .first
  end


  # Return a hash with the lead time for users ordered by next avilable first
  def self.user_lead_times(account, params)
    entries = Entry.lead_time_sql(account, params)

    # Get users
    if params[:user_id].present?
      users = account.users.where(["id = ?", params[:user_id]]).all
    else
      users = account.users.all
    end

    formated_users = {}
    if users.present?
      users.each do |user|
        formated_users[user.id] = {:instance => user, :dates_found => 0}
      end
    end

    # Post process results
    h_entries = Entry.lead_time_post_process_results(entries, formated_users)

    if params[:team_id].present?
      h_entries.keep_if { |_, v| v[:user].teams.map(&:id).include?(params[:team_id].to_i) }
    end

    # Sort
    Hash[h_entries.sort]
  end

  # Number of days that the entry spans over
  def number_of_days
    (self.end_date - self.start_date).to_i + 1
  end


  # Number of days that are remaining
  def number_of_days_left(from = Time.now.in_time_zone.to_date)
    if self.start_date > from
      self.number_of_days
    else
      (self.end_date - from).to_i + 1
    end
  end
  
  
  # Returns the number of minutes that an entry is scheudled for in the given time period
  def self.get_number_of_days_scheduled_for_project_by_period(project, start_period, end_period)
    # Find entries
    entries = Entry.for_project_period(project.id, start_period, end_period)
    total_number_of_days = 0
    
    # Work out number of days
    if entries.present?
      entries.each do |entry|
        # Check is wihtin period and change if requreid for calculation (DONT SAVE!)
        entry.start_date = start_period if entry.start_date < start_period
        entry.end_date = end_period if entry.end_date > end_period
        
        total_number_of_days += entry.number_of_days
      end
    end
    return total_number_of_days
  end

  # Public: Converts this Entry to an ICS format
  #
  # Be aware that you must add these events to an Icalendar::Calendar object
  # or it will be unreadable by most ICS complient clients.
  #
  # Returns an Icalendar::Event
  def to_ics
    event = Icalendar::Event.new
    event.summary = project.name
    event.description = "Project: #{ project.present? ? project.name : 'Untitled' } - Client: #{ project.client.present? ? project.client.name : "No client" }"
    event.start = start_date.to_datetime
                            .change(hour: project.account.account_setting.working_day_start_time.hour)
                            .strftime("%Y%m%dT%H%M%S")
    event.end = end_date.to_datetime
                        .change(hour: project.account.account_setting.working_day_end_time.hour)
                        .strftime("%Y%m%dT%H%M%S")
    event
  end

protected

  # Set the end date to the same as the start date if its blank
  def set_end_date
    self.end_date = self.start_date if self.start_date.present? && self.end_date.blank?
  end


  #
  # Validate that everything belongs to the same account
  def relations_must_belong_to_same_account
    if self.account_id.present?
      if self.user.present?
        errors.add(:user_id, "must belong to the same account") if self.account_id != self.user.account_id
      end

      if self.project.present?
        errors.add(:project_id, "must belong to the same account") if self.account_id != self.project.account_id
      end
    end
  end


  #
  # Validate that the end date is >= to the start date
  def end_date_must_not_be_less_than_start_date
    if self.start_date.present? && self.end_date.present?
      errors.add(:end_date, "can't be before the start date") if self.end_date < self.start_date
    end
  end


  #
  # Validate the creation of the new project if its a new record and merge error messages back
  def new_project_name_is_valid
     if self.project.present? && self.project.new_record?
      unless self.project.valid?
        self.project.errors.full_messages.each do |msg|
          self.errors.add(:project, msg)
        end
      end
    end
  end


  #
  # Try and find project from name and if exists set the id, else build a new one
  def set_project_up_from_name
    if self.account.present? && self.project_name.present? && self.project_id.blank?
      entry_account = self.account
      found_project = entry_account.projects.find_by_name(self.project_name.strip)

      if found_project.present?
        self.attributes = {:project_id => found_project.id, :project_name => nil}
      else
        self.build_project(:name => self.project_name)
        self.project.account_id = self.account_id
      end
    end
  end

    #
    # Post process results to get them into a format that is useable
    def self.lead_time_post_process_results(entries, formated_users)
      # Loop over results
      current_user_loop = 0
      h_entries = {}

      if entries.present?
        entries.each_with_index do |entry, index|
          #duration_inc_weekend = nil
          # If first entry for user, check if date is relevent
          if current_user_loop != entry.user_id
            if entry.date_type == 'end' && entry.gap_date >= Time.now.in_time_zone.to_date
              #duration_inc_weekend = (entry.gap_date - Time.now.in_time_zone.to_date).to_i + 1 # extra 1 is to include today
              # use start date for key
              h_entries["#{Time.now.in_time_zone.to_date}_#{entry.user_id}"] = {:user => formated_users[entry.user_id][:instance], :start_date => Time.now.in_time_zone.to_date, :end_date => entry.gap_date}
              # Increment to user count
              formated_users[entry.user_id][:dates_found] += 1
            end
          end

          # If start results type use this and the next end date
          if entry.date_type == 'start'
            # Check it belongs to the same user
            entry_end = entries[(index + 1)]
            entry_end = nil if entry_end.present? && entry.user_id != entry_end.user_id
            #duration_inc_weekend = (entry.gap_date - entry_end.gap_date).to_i + 1 if entry_end.present? # extra 1 is to include today

            # If end date not present, then theres no further entries after this date for the given user
            # unique key for each date / user

            h_entries["#{entry.gap_date}_#{entry.user_id}"] = {:user => formated_users[entry.user_id][:instance], :start_date => entry.gap_date, :end_date => entry_end.present? ? entry_end.gap_date : nil}
            # Increment user count
            formated_users[entry.user_id][:dates_found] += 1
          end

          current_user_loop = entry.user_id
        end
      end

      # Add all users to entries array that are missing that are missing
      if formated_users.present?
        formated_users.each do |key, h_user|
          if h_user[:dates_found] == 0
            # Add all users that are missing (if no entries in the future they will be missing)
            h_entries["#{Time.now.in_time_zone.to_date}_#{h_user[:instance].id}"] = {:user => h_user[:instance], :start_date => Time.now.in_time_zone.to_date, :end_date => nil}
          end
        end
      end

      return h_entries
    end


    # Sql query for lead time calculation
    def self.lead_time_sql(account, params)
       search_vars = []
      curdate = Time.now.in_time_zone.to_date
      user = account.users.find(params[:user_id]) if params[:user_id].present?

      sql = "SELECT * FROM (
      	SELECT entries.user_id, 'start' AS date_type, (DATE_ADD(entries.end_date, INTERVAL IF(WEEKDAY(entries.end_date) = 4,3,IF(WEEKDAY(entries.end_date) = 5,2,1)) DAY)) AS gap_date
      	FROM entries
      	WHERE NOT EXISTS (
      	    SELECT NULL FROM entries AS e1
      		WHERE e1.start_date <= (DATE_ADD(entries.end_date, INTERVAL IF(WEEKDAY(entries.end_date) = 4,3,IF(WEEKDAY(entries.end_date) = 5,2,1)) DAY))
             	AND e1.end_date >= (DATE_ADD(entries.end_date, INTERVAL IF(WEEKDAY(entries.end_date) = 4,3,IF(WEEKDAY(entries.end_date) = 5,2,1)) DAY))
      		AND e1.user_id = entries.user_id
      	)
      	AND entries.end_date >= '#{Time.now.in_time_zone.to_date}'
      	AND entries.account_id = ?"
      search_vars << account.id
      if params[:user_id].present?
          sql += " AND entries.user_id = ?"
          search_vars << user.id
      end
      sql +=" UNION

      	SELECT entries.user_id, 'end' AS date_type, (DATE_SUB(entries.start_date, INTERVAL IF(WEEKDAY(entries.start_date) = 0,3,IF(WEEKDAY(entries.start_date) = 6,2,1)) DAY)) AS gap_date
      	FROM entries
      	WHERE NOT EXISTS (
      	    SELECT NULL FROM entries AS e1
      		WHERE e1.start_date <= (DATE_SUB(entries.start_date, INTERVAL IF(WEEKDAY(entries.start_date) = 0,3,IF(WEEKDAY(entries.start_date) = 6,2,1)) DAY))
              AND e1.end_date >= (DATE_SUB(entries.start_date, INTERVAL IF(WEEKDAY(entries.start_date) = 0,3,IF(WEEKDAY(entries.start_date) = 6,2,1)) DAY))
      		AND e1.user_id = entries.user_id
      	)
      	AND entries.end_date >= '#{Time.now.in_time_zone.to_date}'
      	AND entries.account_id = ?"
      search_vars << account.id
      if params[:user_id].present?
          sql += " AND entries.user_id = ?"
          search_vars << user.id
      end
      sql +=" ) AS gaps
      ORDER BY 1,3"

      Entry.find_by_sql([sql, *search_vars])
    end

    # Private: Emails the associated User with the change to their Schedule
    def email_schedule_change
      notifier = ScheduleNotifier.new
      notifier.user = user
      notifier.send_notification
    end

end

