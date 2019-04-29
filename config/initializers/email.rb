# Setup MailCatcher. This redirects all mail sent in development to port 1025.
# Comment the following 2 lines to disable MailCatcher and send all email through
# SendGrid instead. (**Really** not reccomended.)
if Rails.env.development?
  ActionMailer::Base.smtp_settings = {
   :address => "localhost",
   :port => 1025,
   :domain => "www.fleetsuite.com"
  }
else
  ActionMailer::Base.smtp_settings = {
      :address => "smtp.sendgrid.net",
      :port => '25',
      :domain => "arthurly.com",
      :authentication => :plain,
      :user_name => "scottarthurly",
      :password => "sendgridarthurly"
  #    :enable_starttls_auto => true
  }
end