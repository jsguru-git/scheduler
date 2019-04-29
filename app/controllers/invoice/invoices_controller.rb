class Invoice::InvoicesController < ToolApplicationController

  # Callbacks
  before_filter :check_invoice_is_active
  before_filter :find_project, :breadcrumbs

  def index
    @invoices = @project.invoices.invoice_date_order

    authorize @invoices, :read?

    respond_to do |format|
      format.html
    end
  end


  def show
    @invoice = @project.invoices.find(params[:id])

    authorize @invoice, :read?

    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new(@invoice, { protocol: request.protocol })
        send_data pdf.render, filename: "Invoice",
                              type: "application/pdf",
                              disposition: "inline"
      end
     end
   end


  def new
    @invoice = @project.invoices.new
    @invoice.set_defaults

    authorize @invoice, :create?

    respond_to do |format|
      format.html
    end
  end


  def create
    @invoice = @project.invoices.new
    @invoice.user_id = current_user.id
    @invoice.attributes = params[:invoice]

    authorize @invoice, :create?

    respond_to do |format|
      if @invoice.save
        flash[:notice] = "Invoice has been successfully created"
        format.html {redirect_to(invoice_project_invoice_path(@project, @invoice))}
      else
        format.html {render :action => 'new'}
      end
    end
  end


  def add_blank_item
    @invoice = @project.invoices.new

    authorize @invoice, :create?

    @invoice.invoice_items.build

    respond_to do |format|
      format.js
    end
  end


  def add_payment_profile
    authorize @project, :create?
    @payment_profiles = @project.payment_profiles.un_invoiced.expected_payment_date_ordered

    respond_to do |format|
      format.js
    end
  end


  def insert_payment_profiles
    @invoice = @project.invoices.new
    authorize @invoice, :update?
    @invoice.invoice_items = InvoiceItem.generate_from_payment_profile(@project, params)

    # Reload payment profiles
    if @invoice.invoice_items.blank?
      flash.now[:alert] = 'Please select at least one payment profile'
      @payment_profiles = @project.payment_profiles.un_invoiced.expected_payment_date_ordered
    end

    respond_to do |format|
      format.js
    end
  end


  # Show form to allow user to select what date period of tracked time should be considered
  def add_tracked_time
    @payment_profiles = @project.payment_profiles.un_invoiced.expected_payment_date_ordered
    authorize @payment_profiles, :update?
    @payment_profiles.delete_if {|payment_profile| payment_profile.service_type_percentage != 100}
    @invoice_item_track = InvoiceItemTrack.new
    @invoice_item_track.set_defaults

    respond_to do |format|
      format.js
    end
  end


  # Insert invoice item based on the tracked time for the given period
  def insert_tracked_time
    authorize @project, :update?
    @invoice_item_track = InvoiceItemTrack.new(params[:invoice_item_track])
    @invoice_item_track.project_id = @project.id

    respond_to do |format|
      if @invoice_item_track.valid?
        @invoice = @project.invoices.new
        @invoice.invoice_items << @invoice_item_track.generate_invoice_items
        format.js
      else
        @payment_profiles = @project.payment_profiles.un_invoiced.expected_payment_date_ordered
        @payment_profiles.delete_if {|payment_profile| payment_profile.service_type_percentage != 100}
        format.js
      end
    end
  end
  
  
  # Change the invoice status
  def change_status
    @invoice = @project.invoices.find(params[:id])

    authorize @invoice, :update?

    @invoice.invoice_status = params[:status]
    
    if @invoice.save
      flash[:notice] = "Status has been successfully changed"
    else
      flash[:alert] = @invoice.errors.full_messages.first
    end
    
    respond_to do |format|
      format.html {redirect_to(invoice_project_invoice_path(@project, @invoice))}
    end
  end
  
  
  # Remove 
  def destroy
    @invoice = @project.invoices.find(params[:id])

    authorize @invoice, :destroy?
    
    if @invoice.invoice_usages.blank?
      InvoiceDeletion.destroy_invoice(@invoice, current_user)
      flash[:notice] = "Invoice has been successfully removed"
    else
      flash[:alert] = "Please remove all associated invoice usages before attempting to delete this invoice"
    end
    
    respond_to do |format|
      format.html {redirect_to(invoice_project_invoices_path(@project))}
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
