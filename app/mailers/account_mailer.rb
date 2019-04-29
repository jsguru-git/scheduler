class AccountMailer < ActionMailer::Base
  
  # Layout
  layout 'email'
  

  # Default
  default from: APP_CONFIG['main']['from-email']


  #
  # Reset password request
  def plan_limit_reached_notification(user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject(APP_CONFIG['env_config']['site_name'] + ' - account limit reached'))
  end


  #
  # After signup
  def signup_complete(user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Thanks for joining " + APP_CONFIG['env_config']['site_name']))
  end


  #
  # 15 days left
  def trial_email_1(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Making the most of FleetSuite"))
  end


  #
  # 2 days left and used account
  def trial_email_2(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Your " + APP_CONFIG['env_config']['site_name'] + " account is about to expire"))
  end


  #
  # 2 days left and not used account
  def trial_email_3(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Your " + APP_CONFIG['env_config']['site_name'] + " free trial has been extended"))
  end


  #
  # On account deletion
  def trial_expired(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Need more time? Save 50% on your FleetSuite subscription"))
  end


  #
  # After signup
  def purchase_complete(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Let us know your thoughts on FleetSuite"))
  end
  
  
  #
  # 5 days after trial is suspended
  def non_user_feedback_request(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Tell us why you're leaving"))
  end
  
  
  #
  # Sent when a user cancels their account
  def account_canceled(account, user)
    @user = user
    @account = user.account
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    mail(:to => MailerTasks.recipients(user.email),
         :subject => MailerTasks.rendered_subject("Tell us why you're leaving"))
  end

end
