# Class to wrap up dropbox and return data / perform actions in a common way to all other provider integrations
require 'dropbox_sdk'
require 'securerandom'

module CloudStorage
  
  
  class DropboxProvider
    
    
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
      client_auth = DropboxOAuth2Flow.new(APP_CONFIG['oauth']['dropbox']['client_id'], APP_CONFIG['oauth']['dropbox']['client_secret'], APP_CONFIG['oauth']['dropbox']['redirect_url'], {}, :dropbox_auth_csrf_token)
      return client_auth.start("#{account.site_address}-#{project.id}-dropbox")
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
        client_auth = DropboxOAuth2Flow.new(APP_CONFIG['oauth']['dropbox']['client_id'], APP_CONFIG['oauth']['dropbox']['client_secret'], APP_CONFIG['oauth']['dropbox']['redirect_url'], {:dropbox_auth_csrf_token => query_params[:state]}, :dropbox_auth_csrf_token)
        access_token, user_id, url_state =  client_auth.finish(query_params)
      rescue
        return false
      end
      
      # Dropbox doesnt seem to support the oauth token refresh and no doc's explaining when tokens expire.
      saved = OauthDriveToken.create_or_update(:user => current_user, 
        :access_token => access_token, 
        :refresh_token => 'not_supported',
        :client_number => user_id, 
        :expires_at => Time.now,
        :provider_number => APP_CONFIG['oauth']['dropbox']['provider_number'])
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
      params[:folder_id] ||= '/'
      
      # Set default params
      result = {:folder_id => params[:folder_id], :parent_folder_id => parent_folder_id, :per_page => 500, :results => []}

      begin
        api_result = @client.metadata(result[:folder_id], 1000, true)
      rescue
        return nil
      end
      
      if api_result.present? && api_result['contents'].present?
        api_result['contents'].each do |item|
          result[:results] << self.item_into_standard_format(item)
        end
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
      
      begin
        api_result = @client.search('', result[:term], result[:per_page])
      rescue
        return nil
      end

      if api_result.present?
        api_result.each do |item|
          result[:results] << self.item_into_standard_format(item)
        end
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
        api_result = @client.metadata(file_id, 1, true)
      rescue
        return nil
      end
      
      if api_result.present?
        self.item_into_standard_format(api_result, true)
      else
        nil
      end
    end


protected


    # Protected: Build a dropbox client instance.
    #
    # current_user - The logged in user
    # perform_auth - Boolean on if authentication should be attempted or not
    # token        - Handed back from oAuth provider
    def build_client(current_user, perform_auth)

      # Authorize and add
      self.authorize!(current_user) if perform_auth
    end


    # Protected: Checks to see if dropbox is authorized for the given user.
    #
    # current_user - The logged in user
    def authorize!(current_user)
      @authorized = false
      
      oauth_drive_token = OauthDriveToken.get_provider_for(current_user, APP_CONFIG['oauth']['dropbox']['provider_number'])
      if oauth_drive_token.present?
        begin
          @client = DropboxClient.new(oauth_drive_token.access_token)
          @authorized = true
        rescue
          oauth_drive_token.destroy
        end
      end
    end
    

    # Protected: Format an item into how FS expects the results to be
    #
    # item - A result from google drive
    #
    # Returns (Hash) result in FS format which is consistent across different platforms
    def item_into_standard_format(item, get_share_link = false)
      file = {}
      file[:id] = item['path']
      file[:provider] = 'dropbox'
      file[:title] = item['path'].split('/').last
      if get_share_link
        file[:view_link] = self.get_share_link(item['path'])
      else
        file[:view_link] = nil
      end
      file[:owner_names] = nil
      file[:created_at] = nil
      file[:mime_type] = item['mime_type'].present? ? item['mime_type'] : 'misc'
      file[:mime_type] = 'folder' if item['is_dir']
      file[:file_type] = self.get_doc_type(item)
      file
    end
    
    
    # Protected: Format an item into how FS expects the results to be
    #
    # file_path - The path to the file
    #
    # Returns (string) The sharable link
    def get_share_link(file_path)
      begin
        api_result = @client.shares(file_path)
      rescue
        return nil
      end

      if api_result.present? && api_result['url'].present?
        api_result['url']
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
      return nil if file_id == '/'
      file_id = file_id.chomp('/')
      file_id.slice(0..(file_id.rindex('/')))
    end
    
    
    # Protected: Get the document type e.g. pdf
    #
    # file_id - The file type
    #
    # Returns (String) the document type
    def get_doc_type(item)
      if item['is_dir']
        "folder"
      elsif item['mime_type'].blank?
        "misc"
      elsif item['mime_type'] == 'application/pdf'
        "pdf"
      elsif item['mime_type'].include?('powerpoint')
        "presentation"
      elsif item['mime_type'] == 'application/zip'
        "zip"
      elsif item['mime_type'] == "application/rtf" || item['mime_type'] == 'text/plain' || item['mime_type'] == 'application/msword' || item['mime_type'].include?('wordprocessing')
        "document"
      elsif item['mime_type'].include?('spreadsheet') || item['mime_type'] == 'ms-excel'
        "spreadsheet"
      elsif item['mime_type'].include?('image') || item['mime_type'] == 'application/vnd.google-apps.drawing'
        "image"
      else
        "misc"
      end
    end


  end
  
    
end
