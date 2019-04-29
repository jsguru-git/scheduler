class Quote::QuoteActivitiesController < ToolApplicationController
  
  
  # Callbacks
  before_filter :find_project_and_quote
  
  
  #
  #
  def new
    @quote_activity = @quote.quote_activities.new(:min_estimated => 0, :max_estimated => 0)
    authorize @quote, :create?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def create
    @quote_activity = @quote.quote_activities.new(params[:quote_activity])
    authorize @quote, :create?
    respond_to do |format|
      if @quote_activity.save
        @quote.update_last_saved_by_to(current_user)
        format.html {
          flash[:notice] = 'Activity has been successfully saved'
          redirect_to quote_project_quote_path(@project, @quote)
        }
        format.js {
          # If we are inserting another
          if params[:commit] != 'Finish'
            @new_quote_activity = @quote.quote_activities.new(:min_estimated => 0, :min_estimated_units => 0, :max_estimated => 0, :max_estimated_units => 0)
          end
        }
      else
        format.html {render :action => 'new'}
        format.js
      end
    end
  end
  
  
  #
  #
  def edit
    authorize @quote, :update?
    @quote_activity = @quote.quote_activities.find(params[:id])
    @quote_activity.attributes = {:min_estimated => @quote_activity.min_estimated_out, :max_estimated => @quote_activity.max_estimated_out, :discount_percentage => @quote_activity.discount_percentage_out}
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def update
    authorize @quote, :update?
    @quote_activity = @quote.quote_activities.find(params[:id])
    
    respond_to do |format|
      if @quote_activity.update_attributes(params[:quote_activity])
        @quote.update_last_saved_by_to(current_user)
        format.html {
          flash[:notice] = 'Activity has been successfully updated'
          redirect_to quote_project_quote_path(@project, @quote)
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
    authorize @quote, :destroy?
    @quote_activity = @quote.quote_activities.find(params[:id])
    @quote_activity.destroy
    @quote.update_last_saved_by_to(current_user)
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Activity has been successfully removed'
        redirect_to quote_project_quote_path(@project, @quote)
      }
      format.js
    end
  end
  
  
  #
  #
  def sort
    authorize @quote, :read?
    if @quote.editable?
      if params[:quote_activity].present?
        params[:quote_activity].each_with_index do |id, index|
          @quote.quote_activities.update_all({position: index+1}, {id: id})
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
