class ScheduleMailer < ActionMailer::Base
  
  # Layout
  layout 'email'
  
  
  # Default
  default from: APP_CONFIG['main']['from-email']


  #
  # Reset password request
  def schedule_mail(account, teams, to_email, start_date, end_date)
    @account = account
    @account_setting = account.account_setting
    @teams = teams
    @start_date = start_date
    @end_date = end_date
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(to_email),
         :subject => MailerTasks.rendered_subject(APP_CONFIG['env_config']['site_name'] + ' - Team schedule'))
  end

  def inform_schedule(account, user, entries, start_date)
    @account = account
    @user = user
    @entries = entries.delete_if{ |e| e.project.name == "Common tasks" }
    @start_date = start_date
    attachments['entries.ics'] = { mime_type: 'text/calendar',
                                   content:    @user.scheduled_projects_ics.to_ical }
    if @entries.present?
      mail(to: MailerTasks.recipients(user.email),
           subject: MailerTasks.rendered_subject("Next weeks schedule"))
    end
  end
  
  
end
