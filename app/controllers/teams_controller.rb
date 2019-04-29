class TeamsController < ToolApplicationController

  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl
  
  before_filter :breadcrumbs

  def index
    @teams = @account.teams.paginate(:page => params[:page],
                                    :per_page => APP_CONFIG['pagination']['site_pagination_per_page']).order('name')
    authorize @teams, :read?
    respond_to do |format|
      format.html
    end
  end

  def show
    @team = @account.teams.find(params[:id])
    authorize @team, :read?
    respond_to do |format|
      format.json { render json: @team.to_json(include: :users) }
    end
  end

  def new
    @team = @account.teams.new
    authorize @team, :create?
    respond_to do |format|
     format.html
     format.js
    end
  end

  def create
    @team = @account.teams.where(name: params[:team][:name]).first

    authorize @team, :create?

    respond_to do |format|
      format.js
    end
  end

  def update
    @team = @account.teams.find(params[:id])
    authorize @team, :update?
    respond_to do |format|
      format.js
    end
  end

  def edit
    @team = @account.teams.find(params[:id])
    authorize @team, :update?
    respond_to do |format|
      format.html
      format.js
    end
  end

  def cancel

    authorize Team, :update?

    respond_to do |format|
     format.html{redirect_to(teams_path)}
     format.js
    end
  end


  def destroy
    @team = @account.teams.find(params[:id])
    authorize @team, :destroy?
    @team.destroy
    flash[:notice] = "Team has been successfully removed"

    respond_to do |format|
      format.html {redirect_to(teams_path)}
    end
  end
  

private
  
  
  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('People', users_path)
    @breadcrumbs.add_breadcrumb('Teams', teams_path) unless params[:action] == 'index'
  end

end
