class DocumentCommentsController < ToolApplicationController
  
  
  # Callbacks
  before_filter :find_project_and_document
  
  
  # Helper method
  helper_method :can_edit?
  
  
  #
  def create
    @document_comment = @document.document_comments.new(params[:document_comment])
    authorize @document_comment, :create?
    @document_comment.user_id = current_user.id
    
    respond_to do |format|
      if @document_comment.save
        format.html {
          flash[:notice] = "Comment has been successfully saved"
          redirect_to project_documents_path(@project)
        }
        format.js
      else
        format.html {
          flash[:alert] = @document_comment.errors.full_messages.first
          redirect_to project_documents_path(@project)
        }
        format.js
      end
    end
  end
  
  
  #
  def edit
    @document_comment = @document.document_comments.find(params[:id])
    authorize @document_comment, :update?
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  def update
    @document_comment = @document.document_comments.find(params[:id])
    authorize @document_comment, :update?
    
    respond_to do |format|
      if @document_comment.update_attributes(params[:document_comment])
        format.html {
          flash[:notice] = 'Comment has been successfully updated'
          redirect_to project_documents_path(@project)
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
    @document_comment = @document.document_comments.find(params[:id])
    authorize @document_comment, :destroy?
    @document_comment.destroy if can_edit?(@document_comment)
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Comment has been successfully removed'
        redirect_to project_documents_path(@project)
      }
      format.js
    end
  end
  
  
  #
  def cancel
    @document_comment = @document.document_comments.find(params[:id])
    authorize @document_comment, :create?

    respond_to do |format|
      format.html { redirect_to project_documents_path(@project) }
      format.js 
    end
  end
  

protected


  #
  #
  def find_project_and_document
    @project = @account.projects.find(params[:project_id])
    @document = @project.documents.find(params[:document_id])
  end
  
  
  # Checks to see if the given user can edit a docuemnt & comment
  def can_edit?(document)
    if has_permission?('account_holder || administrator') || current_user.id == document.user_id
      true
    else
      false
    end
  end
  
  
end
