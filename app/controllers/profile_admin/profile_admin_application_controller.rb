class ProfileAdmin::ProfileAdminApplicationController < ApplicationController


  # Layout
  layout 'profile_admin'


  # SSL
  force_ssl


  # Callbacks
  before_filter :authenticate_admin
  skip_after_filter :verify_authorized


  def authenticate_admin
    authenticate_or_request_with_http_basic do |username, password|
      username == APP_CONFIG['secrets']['profile_admin']['username'] && password == APP_CONFIG['secrets']['profile_admin']['password']
    end
  end


end
