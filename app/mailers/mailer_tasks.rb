class MailerTasks

  # Public: Appends a tag to the subject if not in production
  #
  # subject - The subject to be rendered
  #
  # Returns a String
  def self.rendered_subject(subject)
    subject.prepend "[FS_#{ APP_CONFIG['env_config']['name'] }] " unless APP_CONFIG['env_config']['name'] == 'production'
    subject
  end

  # Public: Returns the correct recipient depending on the server environment
  #
  # Returns an Array
  def self.recipients(email)
    APP_CONFIG['env_config']['actionmailer_recipients'].blank? ? email : 'fleetsuite@arthurly.com'
  end

end