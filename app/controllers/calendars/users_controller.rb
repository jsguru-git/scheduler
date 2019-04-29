class Calendars::UsersController < ToolApplicationController

  # Description: Returns all users ordered by their name
  #
  # Request url: <domain>/calendars/users.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # team_id::
  # - _Type_: Integer
  # - _Default_: nil
  # project_id::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    if params[:team_id].present? || params[:project_id].present?
      a_conditions = []
      a_includes = []


      if params[:team_id].present?
        a_conditions << ["team_users.team_id = ?", params[:team_id]]
        a_includes << :team_users
      end

      if params[:project_id].present?
        a_conditions << ["entries.project_id = ?", params[:project_id]]
        a_includes << :entries
      end

      @users = @account.users.not_archived.includes(a_includes).where([a_conditions.transpose.first.join(' AND '), *a_conditions.transpose.last]).name_ordered
    else
      @users = @account.users.not_archived.name_ordered
    end

    authorize @users, :read?

    respond_to do |format|
      format.json {render :json => @users.to_json(:methods => [:user_calendar_image], :except => [:account_id, :remember_token_expires_at, :remember_token, :password_reset_code, :password_digest])}
    end
  end


  #
  # Description: Returns a users details
  #
  # Request url: <domain>/calendars/users/{id}.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # id (req)::
  # - _Type_: Integer
  # - _Default_: nil
  def show
    @user = @account.users.find(params[:id])
    authorize @user, :read?
    respond_to do |format|
      format.json {render :json => @user.to_json(:methods => [:user_calendar_image], :except => [:account_id, :remember_token_expires_at, :remember_token, :password_reset_code, :password_digest])}
    end
  end


end
