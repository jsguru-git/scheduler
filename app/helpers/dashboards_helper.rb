module DashboardsHelper


  #
  # Decides which tab to show as of default
  def active_dashboard_tab_class(index)
    if params[:active_tab].present? && index.to_s == params[:active_tab]
      'selected'
    elsif params[:active_tab].blank? && index == 2
      'selected'
    else
      ''
    end
  end


  #
  # Decides which tab to show as of default
  def active_generic_tab_class(index, param_name)
    if params[param_name.to_sym].present? && index.to_s == params[param_name.to_sym]
      'selected'
    elsif params[param_name.to_sym].blank? && index == 0
      'selected'
    else
      ''
    end
  end


  #
  # Words out number of days until the given date in words
  def next_available_in_words(av_date)
    if av_date == Time.now.in_time_zone.to_date
      'Today'
    elsif av_date == (Time.now.in_time_zone.to_date + 1.day)
      'Tomorrow'
    else
      fmt_short_date(av_date)
    end
  end


  #
  # Words to show number of days avilabel for
  def available_for_in_words(start_date, end_date)
    if end_date.blank?
      'No further work scheduled'
    else
      duration_inc_weekend = (end_date - start_date).to_i + 1 # extra 1 is to include today

      range = start_date..end_date
      weekdays_in_date_range = range.select { |d| (1..5).include?(d.wday) }.size

      pluralize(duration_inc_weekend, 'day') + " (" + pluralize(weekdays_in_date_range, 'day')  + " excluding weekends)"
    end
  end



end
