class Calendars::ProjectsController < ToolApplicationController

  # Description: Returns all projects ordered by project name
  #
  # Request url: <domain>/calendars/projects.json
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
    @projects = Project.search(@account, params.merge(archived: '0', status: 'open'))
    authorize @projects, :read?
    respond_to do |format|
      format.json {render :json => @projects.to_json}
    end
  end

  def recent
    @projects = Project.joins(:entries).where(entries: { user_id: params[:user_id] })
                       .where('project_status != ?', 'closed').limit(3)
    authorize @projects, :read?

    respond_to do |format|
      format.json {render :json => @projects.to_json}
    end
  end

end
