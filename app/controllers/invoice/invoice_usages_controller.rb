class Invoice::InvoiceUsagesController < ToolApplicationController

  # Callbacks
  before_filter :check_invoice_is_active
  before_filter :find_project, :breadcrumbs
  before_filter :find_invoice, :except => [:index]
  
  
  def index
    @invoices = @project.invoices.pre_payment_invoices
    authorize @invoices, :read?
    respond_to do |format|
      format.html
    end
  end
  
  
  def new
    @invoice_usage = @invoice.invoice_usages.new
    authorize @invoice, :create?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  def edit
    @invoice_usage = @invoice.invoice_usages.find(params[:id])
    authorize @invoice, :update?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  def update
    @invoice_usage = @invoice.invoice_usages.find(params[:id])
    authorize @invoice, :update?
    respond_to do |format|
      if @invoice_usage.update_attributes(params[:invoice_usage])
        format.html {
          flash[:notice] = 'Usage has been successfully updated'
          redirect_to invoice_project_invoice_usages_path(@project)
        }
        format.js
      else
        format.html { render :action => 'edit' }
        format.js { render :action => 'edit' }
      end
    end
  end
  
  
  def create
    @invoice_usage = @invoice.invoice_usages.new(params[:invoice_usage])
    authorize @invoice, :create?
    @invoice_usage.user_id = current_user.id
    
    respond_to do |format|
      if @invoice_usage.save
        format.html {
          flash[:notice] = 'Usage has been successfully added'
          redirect_to invoice_project_invoice_usages_path(@project)
        }
        format.js
      else
        format.html { render :action => 'new' }
        format.js { render :action => 'new' }
      end
    end
  end
  
  
  
  def destroy
    @invoice_usage = @invoice.invoice_usages.find(params[:id])
    authorize @invoice, :destroy?
    @invoice_usage.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Usage has been successfully removed'
        redirect_to invoice_project_invoice_usages_path(@project)
      }
      format.js
    end
  end
  
  

protected


  def find_project
    @project = @account.projects.find(params[:project_id])
  end
  
  
  def find_invoice
    @invoice = @project.invoices.find(params[:invoice_id])
  end
  
  
  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Projects', projects_path)
    @breadcrumbs.add_breadcrumb(@project.name, project_path(@project))
    @breadcrumbs.add_breadcrumb('Invoicing', invoice_project_invoices_path(@project))
  end
    
    
end
