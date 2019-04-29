class Invoice::PaymentProfileRolloversController < ToolApplicationController

  skip_before_filter :ensure_correct_protocol
  force_ssl

  before_filter :find_project

  def edit
    @rollover = @project.payment_profile_rollovers.find(params[:id])
    authorize @rollover.payment_profile, :update?
    #raise ActiveRecord::RecordNotFound if @rollover.blank?
    
    respond_to do |format|
      format.js
    end
  end

  def update
    @rollover = @project.payment_profile_rollovers.find(params[:id])
    authorize @rollover.payment_profile, :update?
    respond_to do |format|
      if @rollover.update_attributes(params[:payment_profile_rollover])
        format.js
      else
        format.js { render :action => 'edit' }
      end
    end
  end

protected
  
  def find_project
    @project = @account.projects.find(params[:project_id])
  end

end
