class TeamUsersController < ToolApplicationController

  def create
    team = @account.teams.find(params[:team_id])
    user = @account.users.find(params[:user_id])

    team.users << user if team && user

    if team.save
      render json: user.to_json
    else
      render json: { status: 422 }
    end
  end

  def destroy
    team_user = TeamUser.where(team_id: params[:team_id])
                        .where(user_id: params[:user_id])
                        .first

    if team_user.destroy
      render :json, { status: 204 }
    end
  end

end