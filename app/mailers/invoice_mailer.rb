class InvoiceMailer < ActionMailer::Base
  
  # Layout
  layout 'email'


  # Default
  default from: APP_CONFIG['main']['from-email']


  # Send email to given email address when an email gets raised
  def invoice_raised(invoice, user_email)
    @invoice = invoice
    @account = invoice.project.account
    @site_host = APP_CONFIG['env_config']['site_host']

    mail(:to => MailerTasks.recipients(user_email),
         :subject => MailerTasks.rendered_subject("New #{APP_CONFIG['env_config']['site_name']} invoice has just been raised"))
  end
  
  
  # Sends email to given email address highlighting expected invoices
  def expected_invoice_mail(account, to_email, payment_profiles, start_date, end_date)
    @account = account
    @account_setting = account.account_setting
    @start_date = start_date
    @end_date = end_date
    @payment_profiles = payment_profiles
    @site_host = APP_CONFIG['env_config']['site_host']

    mail(:to => MailerTasks.recipients(to_email),
         :subject => MailerTasks.rendered_subject(APP_CONFIG['env_config']['site_name'] + ' - Expected invoices'))
  end
  

end
