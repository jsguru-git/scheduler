class PagesController < FrontApplicationController


  def index
    @tweets = Tweet.active.find(:all, :limit => 3)

    respond_to do |format|
      format.html
    end
  end


  def scheduling_tool

    respond_to do |format|
      format.html
    end
  end


  def time_tracking_tool

    respond_to do |format|
      format.html
    end
  end


  def quote_tool

    respond_to do |format|
      format.html
    end
  end


  def invoice_tool

    respond_to do |format|
      format.html
    end
  end


  def signup
    @account_plans = AccountPlan.viewable.expensive_first.find(:all)
    @account_components = AccountComponent.viewable.priority_order.all

    respond_to do |format|
      format.html
    end
  end


  def privacy

    respond_to do |format|
      format.html
    end
  end


  def terms

    respond_to do |format|
      format.html
    end
  end


  def schedule

    respond_to do |format|
      format.html {redirect_to scheduling_tool_path}
    end
  end
  
  
  # Thankyou page after singup containing google tracking code
  def thanks
    @account = Account.find_active_account(params[:account_name])
    raise ActiveRecord::RecordNotFound if @account.blank?
    
    respond_to do |format|
      format.html {render layout: 'tool_blank'}
    end
  end
  
end

