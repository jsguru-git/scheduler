class ProfileAdmin::ProjectsController < ProfileAdmin::ProfileAdminApplicationController


  def index
    @account = Account.find(params[:account_id])
    @projects = @account.projects.paginate(:per_page => 20, :page => params[:page]).order('projects.id')

    respond_to do |format|
      format.html
    end
  end


end
