class Reports::ClientsController < ToolApplicationController

  # Callbacks
  before_filter :breadcrumbs, :report_permissions
  skip_after_filter :verify_authorized

  
  # Profit and loss based on invoice data
  def profit_and_loss
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    
    @all_clients = @account.clients
                           .where(["clients.archived = ?", false])
                           .order("clients.name")

    @clients = @all_clients
               .paginate(page: params[:page], per_page: APP_CONFIG['pagination']['site_pagination_per_page'])
    
    respond_to do |format|
      format.html
    end
  end
  
  
  # Profit and loss based on quote data
  def quote_profit_and_loss
    @all_clients = @account.clients
                           .where(["clients.archived = ?", false])
                           .order("clients.name")

    @clients = @all_clients
               .paginate(page: params[:page], per_page: APP_CONFIG['pagination']['site_pagination_per_page'])
    
    respond_to do |format|
      format.html
    end
  end
  
  
  #
  def project_profit_and_loss
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    
    @client = @account.clients.find(params[:id])
    @projects = Project.includes([:timings, :invoices])
      .group('projects.id')
      .order('projects.name')
      .where(['projects.client_id = ? AND ((timings.started_at <= ? AND timings.ended_at >= ? AND timings.submitted = ?) OR (invoices.invoice_date <= ? AND invoices.invoice_date >= ?))', @client.id, @cal.end_date.end_of_day, @cal.start_date.to_datetime, true, @cal.end_date, @cal.start_date])

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  def quote_project_profit_and_loss
    @client = @account.clients.find(params[:id])
    @projects = Project
      .order('projects.name')
      .where(['projects.client_id = ?', @client.id])

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
private


  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Reports', reports_path)
  end
  
  
end
