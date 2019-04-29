class Oauth::DriveCallbacksController < ToolApplicationController
  
  
  # SSL
  force_ssl
  
  
  # Callbacks
  skip_before_filter :find_account, :only => [:index]
  skip_before_filter :login_required, :only => [:index]
  skip_before_filter :set_timezone, :only => [:index]
  skip_before_filter :ensure_correct_protocol
  skip_before_filter :check_for_suspended_account
  skip_after_filter  :store_location, :verify_authorized
  
  
  # The intial callback url from oauth providers (should simply redirect to the correct subdomain and call the approiate action)
  def index
    subdomain, project_id, provider = params[:state].split('-')
    
    # Remove all other data that is returned in state if dropbox
    state, subdomain = subdomain.split('|') if provider == 'dropbox'
    
    respond_to do |format|
      if provider == 'google'
        format.html {redirect_to google_oauth_drive_callbacks_url(:subdomain => subdomain, :code => params[:code], :project_id => project_id, :error => params[:error])}
      elsif provider == 'dropbox'
        format.html {redirect_to dropbox_oauth_drive_callbacks_url(:subdomain => subdomain, :code => params[:code], :project_id => project_id, :error => params[:error], :state => state)}
      end
    end
  end
  
  
  # Dropbox oAuth callback
  def dropbox
    project = @account.projects.find(params[:project_id])
    
    if params[:error].present?
      flash[:alert] = 'Authorization with Dropbox failed, please try again'
    else
      dropbox_storage = CloudStorage::Base.start(:dropbox, current_user, false)
      success = dropbox_storage.get_oauth_token(params[:code], current_user, params)
      
      if !success
        flash[:alert] = 'Authorization with Dropbox failed, please try again'
      else
        flash[:notice] = 'Authorization with Dropbox was successful'
      end
    end
    
    respond_to do |format|
      format.html {redirect_to project_documents_path(:project_id => project, :from_oauth => 'dropbox')}
    end
  end
  
  
  # Google oAuth callback
  def google
    project = @account.projects.find(params[:project_id])
    
    if params[:error].present?
      flash[:alert] = 'Authorization with google drive failed, please try again'
    else
      google_storage = CloudStorage::Base.start(:google, current_user, false)
      success = google_storage.get_oauth_token(params[:code], current_user)
      
      if !success
        flash[:alert] = 'Authorization with google drive failed, please try again'
      else
        flash[:notice] = 'Authorization with google drive was successful'
      end
    end
    
    respond_to do |format|
      format.html {redirect_to project_documents_path(:project_id => project, :from_oauth => 'google')}
    end
  end
  
  
end
