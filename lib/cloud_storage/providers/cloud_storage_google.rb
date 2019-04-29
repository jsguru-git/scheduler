# Class to wrap up google drive and return data / perform actions in a common way to all other provider integrations
require 'google/api_client'

module CloudStorage
  
  
  class GoogleProvider
    
    
    # Required vars
    attr_reader :client, :authorized
    
    
    # Public: initialize
    def initialize(current_user, perform_auth)
      self.build_client(current_user, perform_auth)
    end


#
# Authroization
#


    # Public: Retrieve authorization URL.
    #
    # account - The associated account
    # project - The associated project
    #
    # Returns (String) the oAuth url to redirect a user to.
    def get_oauth_authorization_link(account, project)
      return @client.authorization.authorization_uri({:state => "#{account.site_address}-#{project.id}-google"}).to_s
    end


    # Public: Exchange an authorization code for OAuth 2.0 credentials.
    #
    # authorization_code - The code passed back from the oauth redirect
    # current_user - The logged in user
    # query_params - The controller params hash
    #
    # Returns (Boolean) true or false depending on if its successful or not
    def get_oauth_token(authorization_code, current_user, query_params = nil)
      begin
        @client.authorization.code = authorization_code
        @client.authorization.fetch_access_token!
      rescue
        return false
      end
      saved = OauthDriveToken.create_or_update(:user => current_user, 
        :access_token => @client.authorization.access_token, 
        :refresh_token => @client.authorization.refresh_token,
        :client_number => @client.authorization.client_id, 
        :expires_at => Time.now + @client.authorization.expires_in.seconds,
        :provider_number => APP_CONFIG['oauth']['google']['provider_number'])
      saved
    end

  
    # Public: Checks to see if google drive us authorized
    #
    # Returns (Boolean) true or false depending on if the current instance has been authorized or not
    def is_authorized?
      @authorized
    end


    # Public: Get folder / file lsiting for the given directory path
    #
    # params - Form params
    #
    # Returns (Hash) Contents of folder in a standard format
    def get_directory_listing_for(params)
      # Get parent folder id
      parent_folder_id = params[:folder_id].present? ? self.get_parent_folder_id(params[:folder_id]) : nil
      
      # Get root folder id if blank
      params[:folder_id] ||= self.get_root_folder_id
      return nil if params[:folder_id].blank?
      
      # Set default params
      result = {:folder_id => params[:folder_id], :parent_folder_id => parent_folder_id, :per_page => 500, :results => []}
      parameters = {}
      parameters['q'] = "'#{params[:folder_id]}' in parents"
      parameters['maxResults'] = result[:per_page]
      
      # Make api request
      begin
        drive = @client.discovered_api('drive', 'v2')
        api_result = @client.execute(:api_method => drive.files.list, :parameters => parameters)
      rescue
        return nil
      end
      
      
      if api_result.status == 200
        files = api_result.data
        files.items.each do |item|
          result[:results] << self.item_into_standard_format(item)
        end
      else
        result[:error] = {:code => api_result.status, :message => api_result.data['error']['message']} 
      end
      result
    end
    

    # Public: Search for files using the given search term
    #
    # params - Form params
    #
    # Returns (Hash) Contents of search in a standard format
    def search_files(params)
      # return if no search term entered
      return nil if params[:term].blank?
 
      result = {:term => params[:term], :current_page => params[:page], :per_page => 100, :previous_page => nil, :next_page => nil, :results => []}
      search_term_escaped = params[:term].gsub("'", %q(\\\'))
      
      # Build out search params
      parameters = {}
      parameters['q'] = "title contains '#{search_term_escaped}'"
      parameters['pageToken'] = result[:current_page].to_s if result[:current_page].to_s.present?
      parameters['maxResults'] = result[:per_page]
      
      begin
        drive = @client.discovered_api('drive', 'v2')
        api_result = @client.execute(:api_method => drive.files.list, :parameters => parameters)
      rescue
        return nil
      end
      
      if api_result.status == 200
        files = api_result.data
        files.items.each do |item|
          result[:results] << self.item_into_standard_format(item)
        end
        # Pagination
        #result[:next_page] = files.next_page_token
      else
        result[:error] = {:code => api_result.status, :message => api_result.data['error']['message']} 
      end
      result
    end
    
    
    # Public: Get the parent folder id 
    #
    # file_id - The file or folder to look-up
    #
    # Returns (Hash) details of the given file in a standard format
    def get_file_details(file_id)
      begin
        drive = @client.discovered_api('drive', 'v2')
        result = @client.execute(:api_method => drive.files.get, :parameters => { 'fileId' => file_id })
      rescue
        return nil
      end
      
      if result.status == 200
        self.item_into_standard_format(result.data) if result.data.present?
      else
        nil
      end
    end


protected


    # Protected: Build a Drive client instance.
    #
    # current_user - The logged in user
    # perform_auth - Boolean on if authentication should be attempted or not
    def build_client(current_user, perform_auth)
      @client = Google::APIClient.new(:application_name => 'FleetSuite')
      @client.authorization.client_id = APP_CONFIG['oauth']['google']['client_id']
      @client.authorization.client_secret = APP_CONFIG['oauth']['google']['client_secret']
      @client.authorization.redirect_uri = APP_CONFIG['oauth']['google']['redirect_url']
      @client.authorization.scope = ['https://www.googleapis.com/auth/drive.readonly.metadata']

      # Authorize and add
      self.authorize!(current_user) if perform_auth
    end


    # Protected: Checks to see if google drive is authorized for the given user. (Will attempt to refresh token if required)
    #
    # current_user - The logged in user
    def authorize!(current_user)
      @authorized = false
      oauth_drive_token = OauthDriveToken.get_provider_for(current_user, APP_CONFIG['oauth']['google']['provider_number'])
      if oauth_drive_token.present?
        # Set details
        @client.authorization.access_token  = oauth_drive_token.access_token
        @client.authorization.refresh_token = oauth_drive_token.refresh_token
        @client.authorization.client_id     = oauth_drive_token.client_number

        if oauth_drive_token.expires_at < Time.now
          # Present but expired, attempt to refresh
          @authorized = true if self.refresh_token(oauth_drive_token)
        elsif self.current_token_still_valid?
          @authorized = true
        else
          # Not valid so destroy it and prompts for re-auth
          oauth_drive_token.destroy
        end
      end
    end
    
    
    # Protected: Checks to see that the token is still valid and hasnt been revoked or anything
    #
    # Returns (Boolean) Depending on if the taken is valid or not
    def current_token_still_valid?
      begin
        drive = @client.discovered_api('drive', 'v2')
        result = @client.execute(:api_method => drive.about.get)
      rescue
        return false
      end
      
      if result.status == 200
        true
      else
        false
      end
    end


    # Protected: Attempt to refresh the token as it has expired, if cant refresh, just remove it.
    #
    # oauth_drive_token - oauth_drive_token instance
    #
    # Returns (Boolean) Depending on if the access token has been updated correctly or not
    def refresh_token(oauth_drive_token)
      begin
        @client.authorization.fetch_access_token!
      rescue
        # Error when updating, so lets remove token and user will have to re-autrhorize
        oauth_drive_token.destroy
        return false
      end
      
      saved = OauthDriveToken.create_or_update(:user => oauth_drive_token.user, 
        :access_token => @client.authorization.access_token, 
        :refresh_token => @client.authorization.refresh_token,
        :expires_at => Time.now + @client.authorization.expires_in.seconds,
        :provider_number => APP_CONFIG['oauth']['google']['provider_number'])

      # Hasn't been updated, so lets remove token
      oauth_drive_token.destroy if !saved
      
      saved
    end


    # Protected: Foprmat an item into how FS expects the results to be
    #
    # item - A result from google drive
    #
    # Returns (Hash) result in FS format which is consistent across different platforms
    def item_into_standard_format(item)
      file = {}
      file[:id] = item.id
      file[:provider] = 'google'
      file[:title] = item.title
      file[:view_link] = item.alternateLink
      file[:owner_names] = item.ownerNames.to_a.join(", ") if item.ownerNames.to_a.present?
      file[:created_at] = item.createdDate
      file[:mime_type] = item.mimeType
      file[:file_type] = self.get_doc_type(item)
      file
    end
    
    
    # Protected: Get the root folder id for a given user
    #
    # Returns (String) the root folder id
    def get_root_folder_id
      begin
        drive = @client.discovered_api('drive', 'v2')
        result = @client.execute(:api_method => drive.about.get)
      rescue
        return nil
      end
    
      if result.status == 200
        result.data.rootFolderId
      else
        nil
      end
    end
    
    
    # Protected: Get the parent folder id 
    #
    # file_id - The file or folder to look-up
    #
    # Returns (String) the folder id
    def get_parent_folder_id(file_id)
      begin
        drive = @client.discovered_api('drive', 'v2')
        result = @client.execute(:api_method => drive.files.get, :parameters => { 'fileId' => file_id })
      rescue
        return nil
      end
      
      if result.status == 200
        result.data.parents[0].id if result.data.parents.present?
      else
        nil
      end
    end
    
    
    # Protected: Get the document type e.g. pdf
    #
    # file_id - The file type
    #
    # Returns (String) the document type
    def get_doc_type(item)
      if item.mimeType.blank?
        "misc"
      elsif item.mimeType == 'application/pdf'
        "pdf"
      elsif item.mimeType == 'application/vnd.google-apps.folder'
        "folder"
      elsif item.mimeType == 'application/vnd.google-apps.presentation'
        "presentation"
      elsif item.mimeType == 'application/zip'
        "zip"
      elsif item.mimeType == "application/rtf" || item.mimeType == 'text/plain' || item.mimeType == 'application/msword' || item.mimeType == 'application/vnd.google-apps.document' || item.mimeType.include?('wordprocessing')
        "document"
      elsif item.mimeType.include?('spreadsheet') || item.mimeType == 'ms-excel'
        "spreadsheet"
      elsif item.mimeType.include?('image') || item.mimeType == 'application/vnd.google-apps.drawing'
        "image"
      else
        "misc"
      end
    end


  end
  
  
end
