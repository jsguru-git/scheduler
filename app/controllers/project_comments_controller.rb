class ProjectCommentsController < ToolApplicationController
  
  
  # Callbacks
  before_filter :find_project, :breadcrumbs
  
  
  # Helper method
  helper_method :can_edit?
  
  
  def index
    @project_comments = @project.project_comments.original_comments.comemnt_date_order

    authorize @project_comments, :read?
    
    respond_to do |format|
      format.html
    end
  end
  
  
  def preview
    @project_comments = @project.project_comments.comemnt_date_order

    authorize @project_comments, :read?
    
    respond_to do |format|
      format.html {redirect_to project_project_comments_path(@project)}
      format.js
    end
  end
  
  
  #
  def create
    @project_comment = @project.project_comments.new(params[:project_comment])
    @project_comment.user_id = current_user.id

    authorize @project_comment, :create?
    
    respond_to do |format|
      if @project_comment.save
        format.html {
          flash[:notice] = "Comment has been successfully saved"
          redirect_to project_project_comments_path(@project)
        }
        format.js
      else
        format.html {
          flash[:alert] = @project_comment.errors.full_messages.first
          redirect_to project_project_comments_path(@project)
        }
        format.js
      end
    end
  end
  
  
  #
  def edit
    @project_comment = @project.project_comments.find(params[:id])

    authorize @project_comment, :update?
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  def update
    @project_comment = @project.project_comments.find(params[:id])

    authorize @project_comment, :update?
    
    respond_to do |format|
      if can_edit?(@project_comment) && @project_comment.update_attributes(params[:project_comment])
        format.html {
          flash[:notice] = 'Comment has been successfully updated'
          redirect_to project_project_comments_path(@project)
        }
        format.js
      else
        format.html { render :action => 'edit' }
        format.js { render :action => 'edit' }
      end
    end
  end
  
  
  #
  def destroy
    @project_comment = @project.project_comments.find(params[:id])

    authorize @project_comment, :destroy?
    @project_comment.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Comment has been successfully removed'
        redirect_to project_project_comments_path(@project)
      }
      format.js
    end
  end
  
  
  #
  def cancel
    @project_comment = @project.project_comments.find(params[:id])

    authorize @project_comment, :create?

    respond_to do |format|
      format.html { redirect_to project_project_comments_path(@project) }
      format.js 
    end
  end
  
  
  #
  def reply
    @project_comment = @project.project_comments.find(params[:id])

    authorize @project_comment, :create?

    @new_project_comment = @project.project_comments.new(:project_comment_id => @project_comment.id)
    
    respond_to do |format|
      format.html
    end
  end
  

  #
  def submit_reply
    @new_project_comment = @project.project_comments.new(params[:project_comment])
    @new_project_comment.user_id = current_user.id
    @project_comment = @project.project_comments.find(@new_project_comment.project_comment_id)

    authorize @project_comment, :create?
    
    respond_to do |format|
      if @new_project_comment.save
        format.html {
          flash[:notice] = "Comment reply has been successfully saved"
          redirect_to project_project_comments_path(@project)
        }
        format.js
      else
        format.html {
          render :action => 'reply'
        }
        format.js
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
  
  
  # Checks to see if the given user can edit a comment
  def can_edit?(comment)
    if has_permission?('account_holder || administrator') || current_user.id == comment.user_id
      true
    else
      false
    end
  end

  
end
