class PhasesController < ToolApplicationController

  skip_before_filter :ensure_correct_protocol
  force_ssl

  def index
    @phases = @account.phases.all
    authorize Phase, :read?
    respond_to do |format|
      format.json { render json: @phases.to_json }
    end
  end

  def show
    @phase = @account.phases.where(id: params[:id])
    authorize @phase, :read?
    respond_to do |format|
      if @phase.present?
        format.json { render json: @phase.to_json }
      else
        format.json { render json: nil, status: 404 }
      end
    end
  end

  def create
    @phase = @account.phases.new(params[:phase])
    authorize @phase, :create?
    respond_to do |format|
      if @phase.save
        format.json { render json: @phase.to_json }
      else
        format.json { render json: nil, status: 406 }
      end
    end
  end

  def destroy
    @phase = Phase.find(params[:id])
    authorize @phase, :destroy?
    respond_to do |format|
      if @phase.destroy
        format.json { render json: nil, status: 204 }
      else
        format.json { render json: nil, status: 406 }
      end
    end
  end

end
