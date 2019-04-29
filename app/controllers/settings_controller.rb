class SettingsController < ToolApplicationController

  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl except: [:update_hopscotch]

  before_filter :breadcrumbs

  def index
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      format.html
    end
  end


  def update
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Settings have been successfully updated"

        format.html { redirect_to(settings_path) }
        format.json { render json: nil, status: 200 }
      else
        format.html { render :action => 'index' }
        format.json { render json: nil, status: 404 }
      end
    end
  end

  def update_hopscotch
    puts "HELLO"
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Settings have been successfully updated"

        format.html { redirect_to(settings_path) }
        format.json { render json: nil, status: 200 }
      else
        format.html { render :action => 'index' }
        format.json { render json: nil, status: 404 }
      end
    end
  end


  def quote
    @account_setting = @account.account_setting

    authorize @account, :read?

    respond_to do |format|
      format.html
    end
  end


  def update_quote
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Quote settings have been successfully updated"

        format.html { redirect_to(quote_settings_path) }
      else
        format.html { render :action => 'quote' }
      end
    end
  end


  def invoice
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      format.html
    end
  end


  def update_invoice
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Invoice settings have been successfully updated"

        format.html { redirect_to(invoice_settings_path) }
      else
        format.html { render :action => 'invoice' }
      end
    end
  end
  
  
  def schedule
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      format.html
    end
  end
  
  
  def update_schedule
    @account_setting = @account.account_setting

    authorize @account, :update?

    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Schedule settings have been successfully updated"

        format.html { redirect_to(schedule_settings_path) }
      else
        format.html { render :action => 'schedule' }
      end
    end
  end
  

  def remove_logo
    @account_setting = AccountSetting.find(params[:id])

    authorize @account, :destroy?
    
    @account_setting.logo.destroy
    @account_setting.save

    redirect_to :back
  end

  def personal
    @user = current_user

    authorize @account, :update?

    respond_to do |format|
      format.html { render 'users/edit' }
    end
  end
  
  def issue_tracker
    @account_setting = @account.account_setting
    @account_setting.decrypt_fields
    @account_setting.issue_tracker_password = nil

    authorize @account, :update?
    
    respond_to do |format|
      format.html
    end
  end
  
  def update_issue_tracker
    @account_setting = @account.account_setting
    @account_setting.updating_issue_tracker_credentails = true

    authorize @account, :update?
    
    respond_to do |format|
      if @account_setting.update_attributes(params[:account_setting])
        flash[:notice] = "Issue tracker settings have been successfully updated"
        format.html { redirect_to(issue_tracker_settings_path) }
      else
        @account_setting.issue_tracker_username = nil
        @account_setting.issue_tracker_password = nil
        format.html { render :action => 'issue_tracker' }
      end
    end
  end

  def inform_overdue_timesheet

    authorize @account, :update?

    users = @account.users.select{ |u| u.days_without_time_tracked.present? }
    users.each do |user|
      UserMailer.overdue_timesheet(user, user.days_without_time_tracked).deliver
    end

    respond_to do |format|
      format.html { redirect_to(settings_path) }
    end
  end

private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Settings', settings_path)
  end

end

