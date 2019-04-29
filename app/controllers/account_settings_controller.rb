class AccountSettingsController < ToolApplicationController


  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl


  # Callbacks
  skip_before_filter :check_for_suspended_account
  before_filter :breadcrumbs

  def index
    authorize Account, :update?
    @account_plans = AccountPlan.viewable.expensive_first.find(:all)
    @account_components = AccountComponent.viewable.order('name').all

    respond_to do |format|
      format.html
    end
  end


  def change_plan
    @account.account_setting.mark_as_reached_limit_email_not_sent if @account.account_setting.reached_limit_email_sent
    authorize @account, :update?
    respond_to do |format|

      updated = @account.update_plan_to(params['account']['account_plan_id'])
      if updated
        flash[:notice] = 'Your account plan has been successfully changed'
      else
        flash[:alert] = 'The chosen plan can not be used for this account'
      end
      format.html {redirect_to account_settings_path}
    end
  end


  # show page asking user to confirm they want their account deleted
  def confirm_remove
    authorize Account, :update?
    respond_to do |format|
      format.html
    end
  end


  def destroy
    @account.mark_to_be_deleted
    authorize @account, :destroy?
    AccountMailer.account_canceled(@account, current_user).deliver

    respond_to do |format|
      format.html {redirect_to root_url(:subdomain => 'www')}
    end
  end


  def payment_details
    authorize Account, :update?
    flash[:notice] = "Your payment details have been successfully updated" unless params[:updated].blank?

    respond_to do |format|
      format.html
    end
  end


  def statements
    authorize @account, :update?
    @statements = @account.get_statements

    respond_to do |format|
      format.html
    end
  end


  def statement
    authorize @account, :update?
    @statement = @account.get_single_statement(params[:statement_id])

    respond_to do |format|
      format.html
    end
  end


  def enable_component
    authorize @account, :update?
    @component = AccountComponent.find(params[:component_id])
    @component.enable_for(@account)

    flash[:notice] = "#{@component.name} has been successfully enabled"
    respond_to do |format|
      format.html {redirect_to account_settings_path}
    end
  end


  def disable_component
    authorize @account, :update?
    @component = AccountComponent.find(params[:component_id])

    # Check there is more than one component enabled
    if @account.account_account_components.length <= 1
      flash[:alert] = "Sorry, #{@component.name} can not be disabled as you must have at least one component active."
    # Check if its beeing used or not
    elsif @component.can_component_be_disabled_for?(@account)
      flash[:notice] = "#{@component.name} has been successfully disabled"
      @component.disable_for(@account)
    else
        flash[:alert] = "Sorry, #{@component.name} can not be disabled whilst it is being used, please remove all data first."
    end

    respond_to do |format|
      format.html {redirect_to account_settings_path}
    end
  end

private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Your Account', account_settings_path)
  end

end

