class UsersController < ToolApplicationController


  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl

  before_filter :breadcrumbs

  # Callbacks
  skip_before_filter :check_for_suspended_account, :only => [:edit, :update]


  def index
    params[:archived] ||= '0'
    @users = User.search_users(@account, params)
    authorize User, :read?
    respond_to do |format|
      format.html
    end
  end


  def show
    @cal = Calendar.new(params)
    @user = @account.users.find(params[:id])
    authorize @user, :read?
    respond_to do |format|
      format.html
      format.json { render json: @user.to_json }
    end
  end


  def new
    @user = @account.users.new
    authorize @user, :create?
    params[:send_invite_email] = 1

    respond_to do |format|
      format.html
    end
  end


  def create
    @user = @account.users.new(params[:user])
    authorize @user, :create?
    success = @user && @user.save
    if success && @user.errors.empty?
      UserMailer.user_added(current_user, @user).deliver unless params[:send_invite_email].blank?
      @user.teams = @account.teams.find(params[:users_teams]) if params[:users_teams]
      @user.roles << Role.find_by_title('member') unless @user.account.users.count == 1
      flash[:notice] = "Person has been successfully created"
      redirect_to users_path
    else
      @user.send_reached_plan_limit_email if @user.errors.include?(:plan) && !has_permission?('account_holder')
      render :action => 'new'
    end
  end


  def edit
    @user = @account.users.find(params[:id])
    authorize @user, :update?
    respond_to do |format|
      format.html
    end
  end


  def update
    @user = @account.users.find(params[:id])
    authorize @user, :update?
    respond_to do |format|
      if @user.update_attributes(params[:user])
        if has_permission?('account_holder || administrator')
          if params[:users_teams]
            @user.teams = @account.teams.find(params[:users_teams])
          else
            @user.teams = []
          end
        end

        @user.update_user_details_in_chargify
        flash[:notice] = "Changes have been saved successfully"

        format.html { redirect_to(:back) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end


  def destroy
    @user = @account.users.find(params[:id])
    authorize @user, :destroy?
    # Cant delete account holder or current user
    if !has_permission?('account_holder', @user) && current_user.id != @user.id
      @user.destroy
      flash[:notice] = "Person has been successfully removed"
    end

    respond_to do |format|
      format.html { redirect_to(users_path) }
    end
  end


  def edit_roles

    if params[:team_id].present?
      @team = Team.find(params[:team_id])
      @users = @team.users
    else
      @users = @account.users.name_ordered
    end

    authorize @users, :update?
    respond_to do |format|
      format.html
    end
  end


  def update_roles
    @user = @account.users.find(params[:user_id])
    current_role = @user.roles.first
    role = Role.find(params[:role_id])

    authorize @user, :update?

    @user.roles = [role] if role    

    respond_to do |format|
      if role.title == 'account_holder' && current_user.roles.first.title != 'account_holder'
        format.json { render json: { errors: 'only account holders can create other account holders' }.to_json, status: :forbidden }
      elsif @user.save
        format.json { render json: @user.to_json }
      else
        @user.roles = [current_role]
        @user.save
        format.json { render json: @user.errors, status: 422 }
      end
    end
  end


private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('People', users_path)
    @breadcrumbs.add_breadcrumb('Employees', users_path) unless params[:action] == 'index'
  end

  #
  # Checks a user has the correct rights to update
  def has_correct_rights
    object = @account.users.find(params[:id])

    if current_user.id == object.id || has_permission?('account_holder || administrator')

    else
      redirect_to root_path
    end
  end
end
