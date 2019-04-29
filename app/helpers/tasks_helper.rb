module TasksHelper
  def task_estimate(task, account)
    if task.quote_activity && task.quote_activity.estimate_type.zero?
      minute_duration_scale_days(task.quote_activity.max_estimated_minutes, account, 2)
    elsif task.quote_activity
      minute_duration_scale_days(task.quote_activity.min_estimated_minutes, account, 2).split(' ').first + ' - ' +
        minute_duration_scale_days(task.quote_activity.max_estimated_minutes, account, 2)
    else
      minute_duration_scale_days(task.estimated_minutes, account, 2)
    end
  end
end
