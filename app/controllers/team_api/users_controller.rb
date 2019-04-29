class TeamApi::UsersController < ToolApplicationController

  force_ssl
  skip_before_filter :ensure_correct_protocol

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def show
    @user = @account.users.find(params[:id])

    authorize @user, :read?

    respond_to do |format|
      format.json { render json: @user.to_json(methods: [:parsed_biography]) }
    end
  end

  def update
    @user = @account.users.find(params[:id])
    authorize @user, :update?
    @user.biography = params[:biography]

    respond_to do |format|
      if @user.save
        format.json { render json: @user.to_json(methods: [:parsed_biography]) }
      else
        format.json { render json: @user.errors.to_json, status: 422 }
      end
    end
  end

  private

  def user_not_authorized
    respond_to do |format|
      format.json { render json: ({ :error => :forbidden }).to_json, status: :forbidden }
    end
    
  end

end