class DocumentsController < ToolApplicationController
  
  
  # Callbacks
  before_filter :find_project, :breadcrumbs
  
  
  # Helper method
  helper_method :can_edit?
  
  
  #
  #
  def index
    @documents = @project.documents.name_ordered

    authorize @documents, :read?

    @google_storage = CloudStorage::Base.start(:google, current_user)
    @dropbox_storage = CloudStorage::Base.start(:dropbox, current_user)
    
    respond_to do |format|
      format.html
    end
  end
  
  
  #
  #
  def new
    authorize Document, :create?
    provider_search
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  #
  #
  def create
    @response = Document.attach_from_provider(@project, current_user, params[:provider], params[:documents])

    authorize Document, :create?

    respond_to do |format|
      if @response[:docs].present?
        format.html {
          flash[:notice] = 'Documents have been attached to project'
          redirect_to project_documents_path(@project)
        }
        format.js
      else
        format.html {
          flash[:alert] = @response[:error] if @response[:error].present?
          redirect_to new_project_document_path(:id => @project, :provider => params[:provider], :browse => params[:browse], :term => params[:term], :folder_id => params[:folder_id])
        }
        format.js {
          flash.now[:alert] = @response[:error] if @response[:error].present?
          provider_search
          render :action => 'new'
        }
      end
    end
  end
  
  
  # Upload form for local files
  def new_upload
    @document = @project.documents.new

    authorize @document, :create?
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  
  # Save upload for lcoal files
  def save_upload
    @document = @project.documents.new(params[:document])

    authorize @document, :create?

    @document.user_id = current_user.id
    @document.provider = 'local'
    
    respond_to do |format|
      if @document.save
        format.html {redirect_to project_documents_path(@project)}
      else
        # Clear on base as paperclip adds messages twice (purposely https://github.com/thoughtbot/paperclip/commit/2aeb491fa79df886a39c35911603fad053a201c0)
        @document.errors[:attachment].clear
        format.html {render 'new_upload'}
      end
    end
  end
  
  
  # Generate a url to allow the user to download a given file. (Active for 60 seconds)
  def show
    @document = @project.documents.find(params[:id])
    authorize @document, :read?
    # 60 - URL will be valid for x number of seconds seconds
    redirect_to URI.parse(@document.attachment.expiring_url(60, 'original')).path
  end
  
  
  #
  #
  def destroy
    @document = @project.documents.find(params[:id])

    authorize @document, :destroy?
    
    @document.destroy
    flash[:notice] = 'Document have been un-attached from the project'

    respond_to do |format|
      format.html { redirect_to project_documents_path(@project) }
    end
  end
  
  
  # Change the logged in user within a provider
  def switch
    OauthDriveToken.remove_oauth_connection_for(current_user, APP_CONFIG['oauth'][params[:provider]]['provider_number'])
    @storage = CloudStorage::Base.start(params[:provider], current_user)
    
    authorize Document, :create?

    respond_to do |format|
      format.html {redirect_to @storage.get_oauth_authorization_link(@account, @project)}
    end
  end
  
  
protected


  #
  #
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
  
  
  #
  # Perform folder or file lookup based on the provider which has been provided
  def provider_search
    params[:browse] ||= 'folder'
    @storage = CloudStorage::Base.start(params[:provider], current_user) if APP_CONFIG['oauth'][params[:provider]].present?
    puts "storage #{ @storage.inspect }"
    if params[:browse] == 'folder'
      @results =  @storage.get_directory_listing_for(params)
    elsif params[:browse] == 'search'
      @results = @storage.search_files(params)
    end
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
