class PaymentProfileMailer < ActionMailer::Base
  
  # Layout
  layout 'email'
  
  # Default
  default from: APP_CONFIG['main']['from-email']
  
  
  # Send email to given email address when an email gets raised
  def new_rollover_alert(rollover, to_email)
    @rollover = rollover
    @account = rollover.account
    @site_host = APP_CONFIG['env_config']['site_host']

    mail(:to => MailerTasks.recipients(to_email),
         :subject => MailerTasks.rendered_subject("New #{APP_CONFIG['env_config']['site_name']} payment profile rollover"))
  end
  
  
end
