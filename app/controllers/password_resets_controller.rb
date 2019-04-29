class PasswordResetsController < ToolApplicationController


  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl


  # Callbacks
  skip_before_filter :login_required
  skip_before_filter :check_for_suspended_account
  skip_after_filter  :verify_authorized


  # Layout
  layout 'tool_blank'


  def new

    respond_to do |format|
      format.html
    end
  end


  def create
    @user = @account.users.find(:first, :conditions => ["email = ?", params[:user][:email]])

    respond_to do |format|
      unless @user.blank?
        UserMailer.password_reset(@user).deliver if @user.make_reset_code

        flash[:notice] = 'Thanks, you will shortly receive an email with your reset link'
        format.html {redirect_to new_session_path }
      else
        flash.now[:alert] = 'Email address has not been found'
        format.html { render "new" }
      end

    end
  end


  def edit
    @user = @account.users.find(:first, :conditions => ["password_reset_code = ?", params[:id]]) if !params[:id].blank?

    respond_to do |format|
      unless @user.blank?
        format.html
      else
        flash[:alert] = 'Reset code has not been found'
        format.html { redirect_to new_session_path }
      end
    end
  end


  def update
    @user = @account.users.find(:first, :conditions => ["password_reset_code = ?", params[:id]]) if !params[:id].blank?
    respond_to do |format|
      unless @user.blank?
        if (!params[:user].blank? && !params[:user][:password_confirmation].blank? && !params[:user][:password].blank?)
          @user.attributes = params[:user]
          current_user = @user
          if current_user.save
            current_user.clear_reset_code
            session[:return_to] = nil
            current_user = nil
            flash[:notice] = 'Your password has been reset'
            format.html { redirect_to new_session_path }
          else
            format.html { render :action => "edit" }
          end
        else
          flash.now[:alert] = "Password and password confirmation can't be blank"
          format.html { render :action => "edit" }
        end
      else
        flash[:alert] = 'Reset code has not been found'
        format.html { redirect_to new_session_path }
      end
    end
  end
end

