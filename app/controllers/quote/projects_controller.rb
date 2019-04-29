class Quote::ProjectsController < ToolApplicationController
  
  
  # Callbacks
  before_filter :check_quote_is_active, :breadcrumbs

  
  #
  def index
    params[:archived] ||= '0'
    @projects = Project.search(@account, params)
    authorize Quote, :read?
    respond_to do |format|
      format.html
    end
  end
  
  
  #
  def search
    @quotes = Quote.search(@account, params)
    authorize Quote, :read?
    respond_to do |format|
      format.html
    end
  end

private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Projects', projects_path) unless params[:action] == 'index'
    # if params[:id]
    #   @project = Project.find(params[:id])
    #   @breadcrumbs.add_breadcrumb(@project.name, project_path(@project))
    # end
  end

end
