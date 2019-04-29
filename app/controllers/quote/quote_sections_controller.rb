class Quote::QuoteSectionsController < ToolApplicationController
  
  
  # Callbacks
  before_filter :find_project_and_quote
  
  
  #
  #
  def update
    authorize @quote, :update?
    @quote_section = @quote.quote_sections.find(params[:id])
    @saved = @quote_section.update_attributes(params[:quote_section])
    
    respond_to do |format|
      if @saved
        @quote.update_last_saved_by_to(current_user)
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
  def create
    authorize @quote, :create?
    @quote_section = @quote.quote_sections.create
    
    respond_to do |format|
      @quote.update_last_saved_by_to(current_user)
      format.html {
        flash[:notice] = 'Section has been successfully added'
        redirect_to quote_project_quote_path(@project, @quote)
      }
      format.js
    end
  end
  
  
  #
  #
  def destroy
    authorize @quote, :destroy?
    @quote_section = @quote.quote_sections.find(params[:id])
    @quote_section.destroy if !@quote_section.cost_section?

    respond_to do |format|
      @quote.update_last_saved_by_to(current_user)
      format.html {
        flash[:notice] = 'Section has been successfully removed' if !@quote_section.cost_section?
        redirect_to quote_project_quote_path(@project, @quote)
      }
      format.js
    end
  end
  
  
  #
  #
  def sort
    if @quote.editable?
      if params[:quote_section].present?
        params[:quote_section].each_with_index do |id, index|
          @quote.quote_sections.update_all({position: index+1}, {id: id})
        end
      end
      @quote.update_last_saved_by_to(current_user)
    end
    
    render nothing: true
  end
  
  
protected


  # Find nested elements
  def find_project_and_quote
    @project = @account.projects.find(params[:project_id])
    @quote = @project.quotes.find(params[:quote_id])
  end
  
    
end
