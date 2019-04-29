class Quote::QuotesController < ToolApplicationController
  
  include ActionView::Helpers::TextHelper
  # Callbacks
  before_filter :check_quote_is_active
  before_filter :find_project, :breadcrumbs
  
  
  # Helper method
  helper_method :can_delete_quote?, :can_update_quote_status?, :simple_format, :strip_tags


  #
  #
  def index
    @quotes = @project.quotes.v1_quotes.live.date_created_ordered
    authorize @quotes, :read?
    respond_to do |format|
      format.html
    end
  end
  

  #
  #
  def create
    @quote = @project.quotes.new
    authorize @quote, :create?
    @quote.set_defaults
    @quote.user_id = current_user.id
    @quote.last_saved_by_id = current_user.id
    
    # If this is a new version
    if params[:quote_id]
      @old_quote = @project.quotes.v1_quotes.find(params[:quote_id])
      @quote.attributes = {:quote_id => @old_quote.id, :new_quote => false}
      @quote.draft = false
    end
    
    @quote.save!
    @quote.create_default_sections!
    
    respond_to do |format|
      format.html {redirect_to quote_project_quote_path(@project, @quote)}
    end
  end
  
  
  #
  #
  def update
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :update?
    @quote.last_saved_by_id = current_user.id
    @saved = @quote.update_attributes(params[:quote]) if @quote.editable?
    
    respond_to do |format|
      if @saved
        format.html {
          flash[:notice] = 'Changes saved'
          redirect_to quote_project_quote_path(@project, @quote)
        }
        format.js
      else
        format.html {
          flash[:alert] = @quote.errors.full_messages.first
          redirect_to quote_project_quote_path(@project, @quote)
        }
        format.js
      end
    end
  end
  
  #
  #
  def show
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :read?
    # remove decimal place if not needed
    @quote.attributes = {:vat_rate => @quote.vat_rate_out, :discount_percentage => @quote.discount_percentage_out}
    
    @v1_quotes = @project.quotes.v1_quotes.where(["quotes.id != ?", @quote.id])
    
    respond_to do |format|
      format.html
      format.rtf { render_rtf(@quote, @project, current_user) }
      format.pdf { render :pdf => "show.pdf.erb", 
                    :layout => 'pdf.html',
                    :show_as_html => params[:debug].present?,
                    :encoding => 'utf8',
                    :margin => { :left => 20, :right => 20, :bottom => 20 },
                    :footer => {
                      :html => { 
                        :template => 'shared/layouts/pdf/footer.pdf.erb'
                      }
                    }
                  }
    end
  end

  def render_rtf(quote, project, current_user)
    document = QuoteRTF.new(quote, project, current_user.name)
    send_data document.to_rtf
  end
  
  #
  #
  def edit_details
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :update?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def update_details
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :update?
    @quote.last_saved_by_id = current_user.id
    
    respond_to do |format|
      if @quote.update_attributes(params[:quote])
        format.html {
          flash[:notice] = 'Quote has been successfully updated'
          redirect_to quote_project_quotes_path(@project)
        }
        format.js
      else
        format.html {render :action => 'edit_details'}
        format.js {render :action => 'edit_details'}
      end
    end
  end
  
  
  #
  #
  def copy_from_previous
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :create?
    @copied = @quote.copy_activities_from_previous_quote
    
    respond_to do |format|
      format.html {
        if @copied == 2
          @quote.update_last_saved_by_to(current_user)
          flash[:notice] = SELECTIONS['quote_copy_reasons'][@copied]
        else
          flash[:alert] = SELECTIONS['quote_copy_reasons'][@copied]
        end
        redirect_to quote_project_quote_path(@project, @quote)
      }
      format.js
    end
  end
  
  
  #
  #
  def destroy
    @quote = @project.quotes.find(params[:id])
    authorize @quote, :destroy?
    if can_delete_quote?(@quote)
      @quote.destroy
      flash[:notice] = 'Quote has been removed'
    else
      flash[:alert] = 'You do not have the correct permissions to remove this quote'
    end
    
    respond_to do |format|
      format.html {redirect_to quote_project_quotes_path(@project)}
    end
  end
  
  
protected


  # Find the related project
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
  
  # Checks to see if the given user can delete a quote
  def can_delete_quote?(quote)
    if (has_permission?('account_holder || administrator') || current_user.id == quote.user_id) && quote.is_latest_version?
      true
    else
      false
    end
  end
  
  
  # Checks to see if the given user can edit a quote status
  def can_update_quote_status?(quote)
    if has_permission?('account_holder || administrator') || quote.quote_status == 0
      true
    else
      false
    end
  end
  
  
end
