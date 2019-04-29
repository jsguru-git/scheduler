namespace :schedule do

  task(:inform_users_of_schedule => :environment) do
    User.all.each do |user|
      notifier = ScheduleNotifier.new
      notifier.user = user
      notifier.send_notification
    end
  end

end
