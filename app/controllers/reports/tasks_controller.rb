class Reports::TasksController < ToolApplicationController
  
  # Callbacks
  before_filter :breadcrumbs, :report_permissions
  skip_after_filter :verify_authorized
  
  def no_estimates
    @tasks = Task.includes([:project, :timings])
      .where(["projects.account_id = ? AND timings.submitted = ? AND tasks.estimated_minutes = ? AND tasks.count_towards_time_worked = ? AND projects.project_status != ?", @account.id, true, 0, true, Project::STATUSES[:closed]])
      .paginate(per_page: 20, page: params[:page])
      .order('projects.name, tasks.name')
    @tasks = @tasks.where(["projects.id = ?", params[:project_id]]) if params[:project_id].present?
    
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
