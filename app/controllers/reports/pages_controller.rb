class Reports::PagesController < ToolApplicationController


  # Callbacks
  before_filter :breadcrumbs, :report_permissions
  skip_after_filter :verify_authorized

  def index
    respond_to do |format|
      format.html
    end
  end
  
  
  # Show form enabling user to select the project they would like to see the report for
  def select_project
    get_default_data
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  # Check if project has been selected and redirect to correct page (remember selections if required)
  def submit_select_project
    set_remember_session_data
    
    respond_to do |format|
      if params[:project_id].present?
        format.html { redirect_to URI.parse(params[:path].gsub('0', params[:project_id])).path }
      else
        get_default_data
        flash.now[:alert] = 'Please select a project'
        format.html { render action: 'select_project' }
      end
    end
  end
  
  
  # Update project select
  def update_project
    if params[:client_id].present?
      @client = @account.clients.find(params[:client_id])
      @projects = @client.projects.not_archived.name_ordered
    else
      @projects = @account.projects.not_archived.name_ordered
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  
private


  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', reports_path)
  end


  # Sets the data to remember the selections
  def set_remember_session_data
    # Rememebr funcionality
    if params[:remember].present?
      cookies[:defaults_report_selection_client_id] = params[:client_id]
      cookies[:defaults_report_selection_project_id] = params[:project_id] 
    else
      cookies[:defaults_report_selection_client_id] = nil
      cookies[:defaults_report_selection_project_id] = nil
    end
  end
  
  
  # Laod data based on defaults or start from scratch
  def get_default_data
    begin # Just incase the project or client has been deleted
      client  = @account.clients.find(cookies[:defaults_report_selection_client_id])   if cookies[:defaults_report_selection_client_id].present?
      project = @account.projects.find(cookies[:defaults_report_selection_project_id]) if cookies[:defaults_report_selection_project_id].present?
    
      params[:client_id] = client.id if client.present?
      params[:project_id] = project.id if project.present?
    rescue
    end

    @clients = @account.clients.name_ordered
    if client.present?
      @projects = client.projects.not_archived.name_ordered
    else
      @projects = @account.projects.not_archived.name_ordered
    end
  end
  
  
end
