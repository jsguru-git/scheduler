module CustomDateTimeHelper


  # Raised when an invalid scale argument is passed
  class InvalidScale < StandardError; end


  #
  # format date to 3rd Jun 2009
  def fmt_long_date(date_time)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']

    if date_time.blank?
      return nil
    else
      pi_day = date_time.strftime("%d").to_i

      return date_time.strftime("#{pi_day}#{pa_date_extensions[pi_day]} %b %Y")
    end
  end
  
  
  #
  # format date to 3rd June 2009
  def fmt_long_date_full_month(date_time)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']

    if date_time.blank?
      return nil
    else
      pi_day = date_time.strftime("%d").to_i

      return date_time.strftime("#{pi_day}#{pa_date_extensions[pi_day]} %B %Y")
    end
  end


  #
  # format date to 3rd Jun 2009
  def fmt_long_date_with_day(date_time)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']

    if date_time.blank?
      return nil
    else
      pi_day = date_time.strftime("%d").to_i

      return date_time.strftime("%a #{pi_day}#{pa_date_extensions[pi_day]} %b %Y")
    end
  end


  #
  # format date to 3rd Jun
  def fmt_short_date(date_time)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']

    if date_time.blank?
      return nil
    else
      pi_day = date_time.strftime("%d").to_i

      return date_time.strftime("#{pi_day}#{pa_date_extensions[pi_day]} %b")
    end
  end


  #
  # format date to Sun 30th
  def fmt_date_day_date(date)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']
    if date.present?
      pi_day = date.strftime("%d").to_i
      return date.strftime("%a #{pi_day}#{pa_date_extensions[pi_day]}")
    end
  end
  
  
  #
  # format date to July 2012
  def fmt_date_month_year(date)
    if date.present?
      return date.strftime("%B %Y")
    end
  end


  #
  # format date to 30th Sun
  def fmt_date_full_day_date(date)
    pa_date_extensions = ['', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'st']
    if date.present?
      pi_day = date.strftime("%d").to_i
      return date.strftime("%A #{pi_day}#{pa_date_extensions[pi_day]}")
    end
  end


  #
  # format date to Sun
  def fmt_date_day(date)
    if date.present?
      return date.strftime("%a").downcase
    end
  end


  #
  #
  def fmt_time(date)
    if date.present?
      return date.strftime("%H:%M")
    end
  end


  # Returns string total minutes in the format x hours y minutes
  def minute_duration_scale_hours(total_mins, account, round_to)
    if total_mins.blank?
      in_hours = 0
      in_minutes = 0
    else
      in_hours = (total_mins / 60).to_i
      in_minutes = (total_mins% 60)
    end
    "#{in_hours} "+ (in_hours == 1 || in_hours == - 1 ? 'hour' : 'hours') + 
    " #{in_minutes} " + (in_minutes == 1 ? 'min' : 'mins')
  end


  # Returns string total days in the format x days
  def minute_duration_scale_days(total_mins, account, round_to)
    # Days
    mins_per_day = account.account_setting.working_day_duration_minutes
    if round_to == 0
      days = (total_mins / mins_per_day).to_i
    else
      days = (total_mins.to_f / mins_per_day.to_f).round(round_to)
    end
    days == 1 ? "#{days} day" : days.to_s + ' days'
  end


  # Returns string total weeks in the format x weeks
  def minute_duration_scale_weeks(total_mins, account, round_to)
    mins_worked_in_week = account.account_setting.number_of_minutes_worked_in_a_week
    if round_to == 0
      weeks = (total_mins / mins_worked_in_week).to_i
    else
      weeks = (total_mins.to_f / mins_worked_in_week.to_f).round(round_to)
    end
    weeks == 1 ? "#{weeks} week" : weeks.to_s + ' weeks'
  end


  # Returns string total months in the format x months
  def minute_duration_scale_months(total_mins, account, round_to)
    mins_worked_in_month = account.account_setting.number_of_minutes_worked_in_a_month
    if round_to == 0
      months = (total_mins / mins_worked_in_month).to_i
    else
      months = (total_mins.to_f / mins_worked_in_month.to_f).round(round_to)
    end
    months == 1 ? "#{months} month" : months.to_s + ' months'
  end


  # Description: outputs readable time e.g. 1 hour 2 mins or 4 days
  # @params
  # total_mins - number of mins to to round to
  # account - account object
  # scale - if to display in hours, days, weeks or months
  # round_to - How many decimal places to round to (default 0)
  def minute_duration_to_human_time(total_mins, account, scale = 0, round_to = 0)
    case scale 
      when 0 then minute_duration_scale_hours(total_mins, account, round_to)
      when 1 then minute_duration_scale_days(total_mins, account, round_to)
      when 2 then minute_duration_scale_weeks(total_mins, account, round_to)
      when 3 then minute_duration_scale_months(total_mins, account, round_to)
      else raise InvalidScale
    end
  end


  def minute_duration_to_short_human_time(total_mins)
    hours = '%02i' % (total_mins.abs / 60).to_i
    minutes = '%02i' % (total_mins.abs % 60)
    total_mins < 0 ? "-#{ hours }:#{ minutes }" : "#{ hours }:#{ minutes }"
  end
end
