class ToolApplicationController < ApplicationController


  # libs
  include AuthenticatedSystem


  # Layout
  layout 'tool'


  # Callbacks
  before_filter :find_account
  before_filter :ensure_correct_protocol
  before_filter :login_required
  before_filter :set_timezone
  before_filter :check_for_suspended_account
  after_filter  :store_location, :except => [:edit, :new, :update, :create, :destroy]
  after_filter :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

protected


  #
  # Find account
  def find_account
    @account = Account.find_active_account(request.subdomain) unless request.subdomain.blank?

    raise ActiveRecord::RecordNotFound if @account.blank?
  end


  #
  # Checks to so see if account is suspended
  def check_for_suspended_account
    redirect_to root_path if @account.account_suspended == true
  end


  def set_timezone
    if logged_in?

        if params[:user_id].present?
          Time.zone = User.find(params[:user_id]).time_zone
        else
          Time.zone = current_user.time_zone || 'UTC'
        end

      # Set the default currency for the account
      Money.default_currency = Money::Currency.new(@account.account_setting.default_currency)
    end
  end


#
# Active components
#


  #
  # Callback for all schedule pages
  def check_schedule_is_active
    raise ActiveRecord::RecordNotFound unless @account.component_enabled?(1)
  end


  #
  # Callback for all track pages
  def check_track_is_active
    raise ActiveRecord::RecordNotFound unless @account.component_enabled?(2)
  end


  #
  # Callback for all estimate pages
  def check_quote_is_active
    raise ActiveRecord::RecordNotFound unless @account.component_enabled?(3)
  end


  #
  # Callback for all invoice pages
  def check_invoice_is_active
    raise ActiveRecord::RecordNotFound unless @account.component_enabled?(4)
  end

  private

  def user_not_authorized
    flash[:notice] = "You are not authorized to perform this action."
    redirect_to request.headers["Referer"] || root_path
  end

  def report_permissions
    raise Pundit::NotAuthorizedError if (current_user.roles.map(&:title) & ['account_holder', 'administrator', 'leader']).empty?
  end

end
