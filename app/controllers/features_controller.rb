class FeaturesController < ToolApplicationController

  # Callbacks
  before_filter :find_project


  def new
    @feature = @project.features.new

    authorize @feature, :create?

    respond_to do |format|
      format.html
      format.js
    end
  end


  def create
    @feature = @project.features.new(params[:feature])

    authorize @feature, :create?

    respond_to do |format|
      if @feature.save
        format.html {
          flash[:notice] = "Feature has been successfully created"
          redirect_to project_tasks_path(@project)
        }
        format.js
      else
        format.html {render :action => 'new'}
        format.js {render :action => 'new'}
      end
    end
  end

  def cancel
    authorize Feature, :create?

    respond_to do |format|
     format.html{redirect_to project_tasks_path(@project)}
     format.js
    end
  end


  def destroy
    @feature = @project.features.find(params[:id])

    authorize @feature, :destroy?

    @tasks = @feature.tasks.all
    @feature.destroy


    respond_to do |format|
     format.html{
       flash[:notice] = "Feature has been successfully removed"
       redirect_to project_tasks_path(@project)
     }
     format.js
    end
  end

  def edit
    @feature = @project.features.find(params[:id])

    authorize @feature, :update?

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @feature = @project.features.find(params[:id])

    authorize @feature, :update?

    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        format.html {
          flash[:notice] = "Feature has been successfully updated"
          redirect_to project_tasks_path(@project)
        }
        format.js
      else
        format.html {render :action => 'edit'}
        format.js {render :action => 'edit'}
      end
    end
  end

protected


  def find_project
    @project = @account.projects.find(params[:project_id])
  end
end
