class TrackApi::ProjectsController < ToolApplicationController

  # Description: Returns all active projects ordered by project name
  #
  # Request url: <domain>/track_api/projects.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # client_id::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    @projects = @account.projects
    authorize @projects, :read?
    respond_to do |format|
      format.json { render :json => @projects.includes(:tasks).to_json(include: [:tasks]) }
    end
  end

  # Description: Updates a single project
  #
  # Request URL: <domain>/track_api/projects.json
  #
  # Request type: PUT
  #
  # Request type: json
  def update
    @project = @account.projects.find(params[:id])
    authorize @project, :update?
    @project.project_status_overridden = true

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.json { render json: @project }
      else
        format.json { render json: { success: false } }
      end
    end
  end

end

