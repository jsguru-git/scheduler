class Reports::InvoicesController < ToolApplicationController

  # Callbacks
  before_filter :breadcrumbs, :report_permissions
  skip_after_filter :verify_authorized
  
  
  def invoice_status
    params[:status] ||= '0'
    @all_invoices = Invoice.where(["projects.account_id = ?", @account.id]).includes(:project).invoice_date_order
    @all_invoices = @all_invoices.where(["invoices.invoice_status = ?", params[:status]]) if params[:status].present?
    @invoices = @all_invoices.paginate(page: params[:page], per_page: APP_CONFIG['pagination']['site_pagination_per_page'])

    respond_to do |format|
      format.html
    end
  end
  
  
  def payment_predictions
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    @results = Project.payment_prediction_results(@account, params, @cal.start_date, @cal.end_date)
    @totals = Project.payment_prediction_totals(@account, params, @cal.start_date, @cal.end_date)
    
    respond_to do |format|
      format.html
    end
  end
  
  
  # List all the deleted invoices for this account
  def deletions
    @all_invoice_deletions = @account.invoice_deletions
      .order("invoice_deletions.created_at desc")
      .includes([:user, :project])

    @invoice_deletions = @all_invoice_deletions
      .paginate(:page => params[:page], :per_page => APP_CONFIG['pagination']['site_pagination_per_page'])
    
    respond_to do |format|
      format.html
    end
  end
  
  
  def normalised_monthly
    @cal = Calendar.new(params)
    if params[:start_date].blank?
      @cal.set_start_end_end_of_month
      @cal.start_date = 11.months.ago.beginning_of_month.to_date
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  
  def allocation_breakdown
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    @invoice_usages = InvoiceUsage.allocated_for_period_and_account(@account, @cal.start_date, @cal.end_date)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  def combined_pre_payments
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    @results = Invoice.search_pre_payments(@account, @cal.start_date, @cal.end_date, params)
    
    respond_to do |format|
      format.html
    end
  end

  
private


  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Reports', reports_path)
  end
    
end
