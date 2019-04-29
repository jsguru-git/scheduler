class ProjectsController < ToolApplicationController

  # Callbacks
  before_filter :check_schedule_is_active, :only => [:schedule]
  before_filter :check_track_is_active, :only => [:track]
  before_filter :dont_edit_common_settings_project, :only => [:edit, :update, :archive, :activate]
  before_filter :breadcrumbs

  def index
    params[:status] ||= 'open'
    @projects = Project.search(@account, params)
    authorize @projects, :read?

    respond_to do |format|
      format.html
    end
  end


  def new
    @project = @account.projects.new
    authorize @project, :create?
    respond_to do |format|
      format.html
    end
  end


  def edit
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    respond_to do |format|
      format.html
    end
  end


  def create
    @project = @account.projects.new(params[:project])
    authorize @project, :create?
    respond_to do |format|
      if @project.save
        flash[:notice] = "Project has been successfully created"
        format.html {redirect_to(project_path(@project))}
      else
        format.html {render :action => 'new'}
      end
    end
  end
  
  
  #
  #
  def update
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    @project.validate_issue_tracker_id = true

    params[:project][:project_status_overridden] = true if params[:project][:project_status] && params[:project][:project_status_overridden].blank?

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = "Changes have been saved successfully"

        format.html { 
          redirect_back_or_default(project_path(@project)) 
        }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
      
  
  #
  #
  def show
    @project = @account.projects.find(params[:id])
    authorize @project, :read?
    @estimate_time = @project.total_estimate
    @tracked_time = @project.total_tracked
    
    # Schedule
    if @account.component_enabled?(1)
      @people_scheduled = @project.all_people_scheduled
      @people_in_next_week = @project.people_scheduled_for_next_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
    end

    # Track
    if @account.component_enabled?(2)
      @tracked_this_week = @project.people_tracked_for_a_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
      @people_tracked = @project.all_people_tracked
    end

    respond_to do |format|
      format.html
    end
  end


  def schedule
    @project = @account.projects.find(params[:id])
    authorize @project, :read?
    @people_scheduled = @project.all_people_scheduled
    @people_in_next_week = @project.people_scheduled_for_next_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
    @cal = Calendar.new(params)

    respond_to do |format|
      format.html
    end
  end


  def track
    @project = @account.projects.find(params[:id])
    authorize @project, :read?
    @estimate_time = @project.total_estimate
    @tracked_time = @project.total_tracked

    @tracked_this_week = @project.people_tracked_for_a_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
    @people_tracked = @project.all_people_tracked

    respond_to do |format|
      format.html
    end
  end


  def archive
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    @project.archive_now

    respond_to do |format|
      flash[:notice] = "Project has been successfully archived"

      format.html { redirect_to(project_path(@project)) }
    end
  end


  def activate
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    @project.un_archive_now

    respond_to do |format|
      flash[:notice] = "Project has been successfully re-activated"

      format.html { redirect_to(project_path(@project)) }
    end
  end
  
  
  def edit_percentage_complete
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    respond_to do |format|
      format.html {redirect_to edit_project_path(@project)}
      format.js
    end
  end
  
  
  def update_percentage_complete
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.js
      else
        format.js {render :action => 'edit_percentage_complete'}
      end
    end
  end


protected

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Projects', projects_path) unless params[:action] == 'index'
    if params[:id]
      @project = Project.find(params[:id])
      @breadcrumbs.add_breadcrumb(@project.name, project_path(@project))
    end
  end

  #
  # Show 404 if try and edit the common settings project as this project should always exist in the same state (created when new account is created)
  def dont_edit_common_settings_project
    @project = @account.projects.find(params[:id])
    raise ActiveRecord::RecordNotFound if @account.account_setting.common_project_id == @project.id
  end
  
  
end
