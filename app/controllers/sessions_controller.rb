class SessionsController < ToolApplicationController

  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl


  # Callbacks
  skip_before_filter :login_required, only: [:new, :create]
  skip_before_filter :check_for_suspended_account
  skip_after_filter  :store_location, :verify_authorized


  # Layout
  layout 'tool_blank'


  def new

    respond_to do |format|
      format.html
    end
  end


  def create
    logout_keeping_session!
    user = User.account_authenticate(params[:email], params[:password], @account)
    respond_to do |format|
      if user
        self.current_user = user
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag

        increase_times_logged_in!
        flash[:notice] = "You have successfully logged in"
        format.html {redirect_back_or_default('/')}
      else
        note_failed_signin
        @email = params[:email]
        @remember_me = params[:remember_me]
        format.html {render "new"}
      end
    end
  end


  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."

    respond_to do |format|
      format.html {redirect_back_or_default('/')}
    end
  end


protected


  # Track failed login attempts
  def note_failed_signin
    flash.now[:alert] = "The email and/or password you entered is invalid"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  # Increase login numbers
  def increase_times_logged_in!
    current_user.number_of_logins += 1
    current_user.save
  end
end
