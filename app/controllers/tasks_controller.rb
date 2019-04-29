class TasksController < ToolApplicationController


  respond_to :html, :json

  # Callbacks
  before_filter :find_project, :breadcrumbs
  before_filter :dont_edit_common_settings_project, :only => [:edit, :update, :destroy, :create, :new]


  #
  #
  def index
    @page_title = 'Activities'
    @page_title << ' (Archived)' if @project.archived

    authorize @project.tasks, :read?

    respond_to do |format|
      format.html
    end
  end


  def show
    @task = @project.tasks.find(params[:id])
    authorize @task, :read?
    respond_with @task
  end


  #
  #
  def new
    @task = @project.tasks.new(params[:task])
    authorize @task, :create?
    respond_to do |format|
      format.html
      format.js
    end
  end


  #
  #
  def create
    @task = @project.tasks.new(params[:task])
    authorize @task, :create?
    respond_to do |format|
      if @task.save
        format.html {
          flash[:notice] = "Task has been successfully created"
          redirect_to project_tasks_path(@project)
        }
        format.js
      else
        format.html {render :action => 'new'}
        format.js {render :action => 'new'}
      end
    end
  end


  #
  #
  def cancel
    authorize Task, :create?

    respond_to do |format|
      format.html{redirect_to project_tasks_path(@project)}
      format.js
    end
  end


  #
  #
  def destroy
    @task = @project.tasks.find(params[:id])
    authorize @task, :destroy?
    begin
      @task.destroy
      @destroyed = true
    rescue ActiveRecord::DeleteRestrictionError
      @destroyed = false
    end

    respond_to do |format|
      format.html {
        if @destroyed
          flash[:notice] = "Task has been successfully removed"
        else
          flash[:alert] = "Task has some time entries so can not be removed"
        end
        redirect_to project_tasks_path(@project)
      }
      format.js
    end
  end


  #
  #
  def edit
    @task = @project.tasks.find(params[:id])
    authorize @task, :update?
    @task.attributes = {:estimated => @task.estimated_out}

    respond_to do |format|
      format.html
      format.js
    end
  end


  #
  #
  def update
    @task = @project.tasks.find(params[:id])
    authorize @task, :update?
    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html {
          flash[:notice] = "Task has been successfully updated"
          redirect_to project_tasks_path(@project)
        }
        format.js
      else
        format.html {render :action => 'edit'}
        format.js {render :action => 'edit'}
      end
    end
  end

  def archive
    @task = @project.tasks.find(params[:id])
    authorize @task, :update?

    @task.archived = params[:task][:archived]
    respond_to do |format|
      if @task.save
        format.html {
          flash[:notice] = "Task has been archived"
          redirect_to project_tasks_path(@project)
        }
      else
        format.html { redirect_to project_tasks_path(@project) }
      end
    end
  end

  #
  #
  def sort
    authorize @project, :read?
    if params[:feature_id].present?
      feature = @project.features.find(params[:feature_id])
      feature_id = feature.id
    else
      feature_id = nil
    end


    if params[:task].present?
      params[:task].each_with_index do |id, index|
        @project.tasks.update_all({position: index+1, feature_id: feature_id}, {id: id})
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def new_import_quote
    @quotes = @project.quotes.live.date_created_ordered
    authorize @project.tasks, :create?
    respond_to do |format|
      format.js
    end
  end

  def import_quote
    @new_tasks = []
    @quote = @project.quotes.find(params[:quote_id])
    authorize @project.tasks, :create?

    @quote.quote_activities.each do |a|
      @new_tasks << @project.tasks.create(a.to_task_attributes)
    end

    respond_to do |format|
      format.js
    end
  end


  protected


  #
  #
  def find_project
    @project = @account.projects.find(params[:project_id])
  end

  def breadcrumbs
    if @project
      @breadcrumbs.add_breadcrumb('Dashboard', root_path)
      @breadcrumbs.add_breadcrumb('Projects', projects_path)
      @breadcrumbs.add_breadcrumb(@project.name, project_path(@project))
    end
  end

  #
  # Show 404 if try and edit the common settings project as this project should always exist in the same state (created when new account is created)
  def dont_edit_common_settings_project
    raise ActiveRecord::RecordNotFound if @account.account_setting.common_project_id == @project.id
  end



end
