class Invoice::ProjectsController < ToolApplicationController

  # Callbacks
  before_filter :check_invoice_is_active


  def index
    params[:archived] ||= '0'
    @projects = Project.search(@account, params)
    authorize @projects, :read?
    respond_to do |format|
      format.html
    end
  end
end

