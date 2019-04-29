class Invoice::PaymentProfilesController < ToolApplicationController 
  
  # Callbacks
  before_filter :check_invoice_is_active
  before_filter :find_project, :breadcrumbs
  
  
  #
  # 
  def index
    params[:stages] = 0 if params[:stages].blank?
    @payment_profiles = PaymentProfile.search_stages(@project, params)
    authorize @payment_profiles, :read?
    respond_to do |format|
      format.html
    end
  end
  
  
  #
  # 
  def new
    @payment_profile = @project.payment_profiles.new
    authorize @payment_profile, :create?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def create
    @payment_profile = @project.payment_profiles.new
    authorize @payment_profile, :create?
    @payment_profile.attributes = params[:payment_profile]
    
    respond_to do |format|
      if @payment_profile.save
        format.html {
          flash[:notice] = "Payment stage has been successfully created"
          redirect_to(invoice_project_payment_profiles_path(@project))
        }
        format.js {
          @payment_profile.rate_card_payment_profiles.build
        }
      else
        format.html {render :action => 'new'}
        format.js {render :action => 'new'}
      end
    end
  end
  
  
  #
  #
  def edit
    @payment_profile = @project.payment_profiles.find(params[:id])
    authorize @payment_profile, :update?
    raise ActiveRecord::RecordNotFound if @payment_profile.invoice_item.present? # Dont allow invoiced profiles to be edited
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def update
    @payment_profile = @project.payment_profiles.find(params[:id])
    authorize @payment_profile, :update?
    @payment_profile.last_saved_by_id = current_user.id
    raise ActiveRecord::RecordNotFound if @payment_profile.invoice_item.present? # Dont allow invoiced profiles to be edited
    
    respond_to do |format|
      if @payment_profile.update_attributes(params[:payment_profile])
        
        format.html {
          flash[:notice] = "Payment stage has been successfully updated"
          redirect_to(invoice_project_payment_profiles_path(@project))
        }
        format.js
      else
        format.html {render :action => 'edit'}
        format.js {render :action => 'edit'}
      end
    end
  end
  
  
  #
  #
  def destroy
    @payment_profile = @project.payment_profiles.find(params[:id])
    authorize @payment_profile, :update?
    @payment_profile.destroy
    flash[:notice] = "Payment stage has been successfully removed"
    
    respond_to do |format|
      format.html {redirect_to(invoice_project_payment_profiles_path(@project))}
    end
  end
  
  
  #
  #
  def edit_service_types
    @payment_profile = @project.payment_profiles.find(params[:id])
    authorize @payment_profile, :update?
    raise ActiveRecord::RecordNotFound if @payment_profile.invoice_item.present? # Dont allow invoiced profiles to be edited
    @payment_profile.rate_card_payment_profiles.build if @payment_profile.rate_card_payment_profiles.blank?
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def update_service_types
    @payment_profile = @project.payment_profiles.find(params[:id])
    authorize @payment_profile, :update?
    raise ActiveRecord::RecordNotFound if @payment_profile.invoice_item.present? # Dont allow invoiced profiles to be edited
    
    respond_to do |format|
      if @payment_profile.update_attributes(params[:payment_profile])
        # Recalculate if all payment profiles are blank. (After save calculate_cost_based_on_mins callback not called when deleteing service types)
        if @payment_profile.rate_card_payment_profiles.blank? && @payment_profile.expected_minutes != 0
          @payment_profile.calculate_cost_based_on_mins
          @payment_profile.save!
        end
        
        format.html {
          flash[:notice] = "Payment stage has been successfully updated"
          redirect_to(invoice_project_payment_profiles_path(@project))
        }
        format.js
      else
        format.html {render :action => 'edit_service_types'}
        format.js {render :action => 'edit_service_types'}
      end
    end
  end
  
  
  #
  # Render another selection for rate cards
  def add_rate_card_select
    @payment_profile = @project.payment_profiles.new
    authorize @payment_profile, :update?
    @payment_profile.rate_card_payment_profiles.build
    
    respond_to do |format|
      format.js
    end
  end
  
  
  #
  # Show form to collect dates required to generate payment stages from schedule
  def generate_from_schedule
    @auto_payment_profile = AutoPaymentProfile.new
    authorize PaymentProfile, :update?
    @auto_payment_profile.set_defaults_for(@project)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  # Attempt to generate the payment profile from schedule and passed in params
  def generate_from_schedule_save
    @auto_payment_profile = AutoPaymentProfile.new(params[:auto_payment_profile])
    authorize PaymentProfile, :update?
    respond_to do |format|
      if @auto_payment_profile.valid?
        @payment_profiles = @auto_payment_profile.create_payment_stages_for(@project)
        
        format.html {
          flash[:notice] = "Payment stages have been successfully created"
          redirect_to(invoice_project_payment_profiles_path(@project))
        }
        format.js
      else
        format.html {render :action => 'generate_from_schedule'}
        format.js {render :action => 'generate_from_schedule'}
      end
    end
  end
  
  
protected

  
  def find_project
    @project = @account.projects.find(params[:project_id])
  end

  def breadcrumbs
    if @project
      @breadcrumbs.add_breadcrumb('Dashboard', root_path)
      @breadcrumbs.add_breadcrumb('Projects', projects_path)
      @breadcrumbs.add_breadcrumb(@project.name, project_path(@project))
    end
  end

end
