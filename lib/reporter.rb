# A module that generates reports for Time Tracking
#
# --- Example
#
#   # Generate a report for user with id 5
#
#   report = Reporter::TimeReport.new(5)
#   report.to_csv(Date.today, Date.today - 1.week) -> csv_file

module Reporter

  class TimeReport

    attr_accessor :user, :project_id

    # Regex for matching on leading zero i.e 01, 02 etc
    LEADING_ZERO_EXP = /\A0+/

    # Constructor
    #
    # @param [integer] user_id
    def initialize(user_id, opts={})
      @user = User.find(user_id)
      @project_id = opts[:project_id] if opts[:project_id].present?
    end

    # Group the data by day {"date" : [timings]}
    #
    # @param [date] start_date
    # @param [date] end_date
    #
    # @return [array[object]] timings grouped by day
    def get_timings_in_range(start_date, end_date)
      timings = Timing.submitted_for_period(@user.id, start_date, end_date)
      timings = timings.where(project_id: @project_id) if @project_id
      timings.group_by {|t| t.started_at.beginning_of_day }
    end

    # Formats a date object
    #
    # @param [date]
    #
    # @return [string] the object converted into the expected format.
    def format(t)
      t.strftime("%A %d %B %Y")
    end

    # Gets task name but checks if task is nil first.
    def safe_task_name(timing)
        timing.task.present? ? timing.task.name : "n/a"
    end

    def safe_get_counts_towards_time_worked(timing)
      if timing.task.present? 
        timing.task.count_towards_time_worked?
      else
        false
      end
    end

    # Get the required information from a timing object
    #
    # @param [active record timing]
    #
    # @return [object]
    def get_data(timing)

      task_name = safe_task_name(timing)
      task_counts = safe_get_counts_towards_time_worked(timing)
  
      { project:    timing.project.name,
        task:       task_name,
        notes:      timing.notes,
        started_at: format(timing.started_at),
        ended_at:   format(timing.ended_at),
        duration:   minutes_to_s(timing.duration_minutes),
        duration_mins: timing.duration_minutes,
        counts:     task_counts }
    end

    # Get an array of column names
    #
    # @return [array]
    def get_csv_columns
      %w(Project Task Notes Start End Duration Duration(Mins) Tracked)
    end

    def sum_time_worked(timings)
      timings.inject (0) do |accumulator, timing|
        if timing.task && timing.task.count_towards_time_worked?
          accumulator + timing.duration_minutes
        else
          accumulator
        end
      end
    end

    # Get the total hours worked by summing all the timings
    #
    # @return [integer] sum of total time worked in minutes
    def total_time_worked(timings)
      values = timings.values
      return 0 unless values.present?
      data = []
      values.each do |val|
        data.push(sum_time_worked(val))
      end
      data.inject(&:+)
    end

    # Removes trailing zero for numerical strings
    #
    # @return [string]
    def remove_leading_zero(str)
      return "0" if str == "00"
      str.sub LEADING_ZERO_EXP, ''
    end

    # Return the working day duration in minutes for the current user
    #
    # @return [integer] working day duration minutes
    def working_day_duration
      account = @user.account
      account.account_setting.working_day_duration_minutes
    end

    # The expected working time in minutes
    #
    # @param [integer] number_of_days
    # @param [integer] working_day_duration
    #
    # @return [integer] expected working time in minutes
    def expected_time(number_of_days)
      number_of_days * working_day_duration
    end

    # Convert minutes (int) to string representing HH:mm
    #
    # @param [integer] minutes
    # @return [string] xx hours yy minutes
    def minutes_to_s(minutes)
      Time.at((minutes * 60)).utc.strftime("%H hours %M minutes")
    end

    # Takes a string in format HH:mm and returns x hours y minutes
    #
    # @param [string] "02 hours 23 minutes"
    #
    # @return [string] "2 hours 23 minutes
    def format_result(time_string)
      parts   = time_string.split(' ')
      hours   = remove_leading_zero(parts.first)
      rest    = parts.slice(1,parts.length-1)
      [hours, rest.flatten].join(' ')
    end

    # Given a timings collection calculate the total time worked
    #
    # @param [active record collection]
    #
    # @return [string] "6 hours 23 minutes"
    def calculate_total(timings)
      total_minutes = total_time_worked(timings)
      result = minutes_to_s(total_minutes)
      format_result(result)
    end

    # Flexi calculated by substracting actual from expected
    #
    # @param [active record collection]
    #
    # @return [string] x hours y minutes
    def calculate_flexi(timings)
      total = total_time_worked(timings)
      # Dont count non working days
      no_days = 0
      timings.each do |timing|
        no_days += 1 if @user.account.account_setting.working_days[timing[0].strftime("%A").downcase.to_sym] == '1'
      end
      
      result = (total - (expected_time(no_days)))
      format_result(minutes_to_s(result))
    end

    # Generates a time report csv file
    #
    # @param [date] start_date
    # @param [date] end_date
    #
    # @return [string] comma separated value string
    def to_csv(start_date, end_date)
      group_timings = get_timings_in_range(start_date, end_date)
      CSV.generate do |csv|
        columns = get_csv_columns()
        csv << columns
        group_timings.each_with_index do |(k, v), index|
          csv << []
          csv << [ format(k) ]
          csv << []
          v.each do |timing|
            csv << get_data(timing).values
          end
          total = calculate_total({k => v})
          csv << []
          csv << ["TOTAL", total]
        end
        csv << []
        csv << ["TOTAL", "#{calculate_total(group_timings)}"]
        csv << ["Flexi time", "#{calculate_flexi(group_timings)}"]
      end
    end
  end # end class
end # end module

