class TeamApi::TeamsController < ToolApplicationController

  skip_before_filter :ensure_correct_protocol
  force_ssl

  def show
    @team = @account.teams.where(id: params[:id]).first

    authorize Team, :read?

    respond_to do |format|
      if @team.nil?
        format.json { render json: nil, status: :not_found }
      else
        format.json { render json: @team.to_json(include: :users) }
      end
    end
  end

  def update

    @team = @account.teams.where(id: params[:id]).first

    authorize @team, :update?

    if params.has_key?(:users) && params[:users].nil?
      @team.users = []
    elsif params.has_key?(:users)
      @team.users = []

      params[:users].each do |user_attributes|
        user = @account.users.find(user_attributes["id"])
        @team.users << user if user
      end
    end

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.json { render json: @team.to_json(include: :users) }
      end
    end
  end

  def create

    @team = @account.teams.new(params[:team])

    authorize @team, :create?

    if params[:users]
      params[:users].each do |user_attributes|
        user = @account.users.find(user_attributes[:id])
        @team.users << user if user
      end
    end

    respond_to do |format|
      if @team.save
        format.json { render json: @team.to_json(include: :users) }
      else
        format.json { render json: nil, status: :unprocessable_entity }
      end
    end
  end
end

