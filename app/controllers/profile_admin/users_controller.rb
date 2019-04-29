class ProfileAdmin::UsersController < ProfileAdmin::ProfileAdminApplicationController


  def index
    @account = Account.find(params[:account_id])
    @users = @account.users.paginate(:per_page => 20, :page => params[:page]).order('users.id')

    respond_to do |format|
      format.html
    end
  end


end
