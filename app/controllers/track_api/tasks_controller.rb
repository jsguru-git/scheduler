class TrackApi::TasksController < ToolApplicationController


  # Callbacks
  before_filter :find_project


  #
  # Description: Returns all tasks ordered by name
  #
  # Request url: <domain>/track_api/projects/{project_id}/tasks.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # project_id (req)::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    @tasks = @project.tasks.name_ordered
    authorize @tasks, :read?
    respond_to do |format|
      format.json {render :json => @tasks.to_json()}
    end
  end

  protected

  def find_project
    @project = @account.projects.find(params[:project_id])
  end
end

