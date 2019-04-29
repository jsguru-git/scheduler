module AuthenticationLogic

  # Stuff directives into including module
  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  # Class Methods
  module ModelClassMethods

    # Authenticate request from the API using http basic
    def authenticate_api_request(email, password)
      user = User.find_by_email(email.downcase)
      user && user.authenticate(password) ? user : nil
    end

    # Authenticates a user by their login name and unencrypted password.
    # Returns the user or nil.
    def account_authenticate(email, password, account)
      return nil if email.blank? || password.blank? 
      u = account.users.find_by_email(email.downcase) # need to get the salt
      u && u.archived == false && u.authenticate(password) ? u : nil
    end

    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end

    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end
  end

  # Instance Methods
  module ModelInstanceMethods

    def remember_token?
      (!remember_token.blank?) &&
       remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
    end

    #
    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      remember_me_for 2.weeks
    end

    def remember_me_for(time)
      remember_me_until time.from_now.utc
    end

    def remember_me_until(time)
      self.remember_token_expires_at = time
      self.remember_token = self.class.make_token
      save(:validate => false)
    end

    #
    # refresh token (keeping same expires_at) if it exists
    def refresh_token
      if remember_token?
        self.remember_token = self.class.make_token
        save(:validate => false)
      end
    end

    #
    # Deletes the server-side record of the authentication token. The
    # client-side (browser cookie) and server-side (this remember_token) must
    # always be deleted together.
    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token = nil
      save(:validate => false)
    end

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      UserMailer.password_reset(self).deliver
    end

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

    def make_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      self.save(:validate => false)
    end

    def clear_reset_code
      self.password_reset_code = nil
      self.save(:validate => false)
    end
  end # instance methods
end

