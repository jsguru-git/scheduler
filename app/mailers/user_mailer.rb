class UserMailer < ActionMailer::Base
   
  # Layout
  layout 'email'
  
  # Default
  default from: APP_CONFIG['main']['from-email']


  # Reset password request
  def password_reset(user)
    @user = user
    @site_host = APP_CONFIG['env_config']['site_host']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject(APP_CONFIG['env_config']['site_name'] + ' - Request to change your password'))
  end


  # Send new user email
  def user_added(added_by_user, new_user)
    @added_by_user = added_by_user
    @new_user = new_user
    @account = new_user.account
    @site_name = APP_CONFIG['env_config']['site_name']
    @site_host = APP_CONFIG['env_config']['site_host']

    mail(:to => MailerTasks.recipients(new_user.email),
    :subject => MailerTasks.rendered_subject("#{added_by_user.firstname} has just added you to #{APP_CONFIG['env_config']['site_name']}"))
  end

  # Remind user to submit their timesheet
  def overdue_timesheet(user, dates)
    @site_name = APP_CONFIG['env_config']['site_name']
    @site_host = APP_CONFIG['env_config']['site_host']
    @user = user
    @dates = dates
    @account = user.account
    mail(to: MailerTasks.recipients(user.email),
         subject: MailerTasks.rendered_subject('Your timesheet is overdue!'))
  end


end
