class AccountsController < FrontApplicationController

  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl


  # Callbacks
  before_filter :find_plan, :except => [:verify_suite]


  # TODO test
  def verify_suite
    respond_to do |format|
      if params[:plan_id].blank? || params[:component_id].blank?
        flash[:alert] = "Please select at least one tool for your suite."
        format.html {redirect_to pricing_url(:protocol => 'http', :plan_id => params[:plan_id], :component_id => params[:component_id], :from => params[:from]) }
      else
        format.html {redirect_to new_account_path(:plan_id => params[:plan_id], :component_id => params[:component_id])}
      end
    end
  end


  def new
    @account = Account.new
    @account.users.build

    respond_to do |format|
      format.html
    end
  end



  def create
    @account = Account.new(params[:account])
    @account.account_plan_id = @account_plan.id

    respond_to do |format|
      if @account.save
        @account.account_components << @account_components
        @account.save!

        format.html {
          AccountMailer.signup_complete(@account.users.first).deliver
          redirect_to thankyou_path(:account_name => @account.site_address)
        }
      else
        format.html { render :action => 'new' }
      end
    end
  end


protected


  # Only allow free plans to use this form
  def find_plan
    @account_plan = AccountPlan.find(params[:plan_id])
    @account_components = AccountComponent.all
    raise ActiveRecord::RecordNotFound if @account_plan.blank? || @account_components.blank?

    @account_components.delete_if {|componenet| !params[:component_id].include?(componenet.id.to_s) }
  end
end
