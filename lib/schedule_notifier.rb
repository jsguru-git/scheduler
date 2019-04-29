class ScheduleNotifier

  attr_accessor :user

  # Public: Sends an email if required
  def send_notification(week_beginning = Date.today.next_week)
    entries = user.entries.where(start_date: Date.today.next_week...Date.today.next_week.end_of_week - 2)
    send_schedule_notification(entries, week_beginning)
  end

  protected

  # Private: Sends out a notification to the User if required
  def send_schedule_notification(entries, start_date)
    if entries.present?
      ScheduleMailer.inform_schedule(user.account, user, entries, start_date).deliver
    end
  end

end