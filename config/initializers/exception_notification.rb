if Rails.env.production?

Scheduling::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[FleetSuite ERRORS]",
  :sender_address => %{"FleetSuite Application Error" <info@fleetsuite.com>},
  :exception_recipients => %w{fleetsuite@arthurly.com}
end