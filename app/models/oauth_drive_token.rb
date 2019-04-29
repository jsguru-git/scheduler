class OauthDriveToken < ActiveRecord::Base
  
  
  # External libs
  
  
  # Relationships
  belongs_to :user
  
  
  # Validation
  validates :user_id, :provider_number, :access_token, :refresh_token, :expires_at, :presence => true
  validates :provider_number, :uniqueness => {:scope => :user_id}
  
  
  # Callbacks
  
  
  # Mass assignment protection
  attr_accessible :access_token, :refresh_token, :client_number, :expires_at
  
  
  # Plugins
  
  
#
# Extract functions
#


  # Named scopes


  # Attempt to extract a record for a user if exists
  def self.get_provider_for(user, provider_number)
    user.oauth_drive_tokens.where(["provider_number = ?", provider_number]).first
  end


#
# Save functions
#


  # Create record or update if user already has record for that provider
  def self.create_or_update(args = {})
    args.assert_valid_keys(:user, :access_token, :refresh_token, :client_number, :expires_at, :provider_number)
    
    if args[:user].present? && args[:provider_number].present?
      oauth_drive_token = OauthDriveToken.get_provider_for(args[:user], args[:provider_number])
      
      if oauth_drive_token.blank?
        oauth_drive_token = args[:user].oauth_drive_tokens.new
        oauth_drive_token.provider_number = args[:provider_number] if args[:provider_number].present?
      end
    
      oauth_drive_token.access_token  = args[:access_token] if args[:access_token].present?
      oauth_drive_token.refresh_token = args[:refresh_token] if args[:refresh_token].present?
      oauth_drive_token.expires_at    = args[:expires_at] if args[:expires_at].present?
      oauth_drive_token.client_number = args[:client_number] if args[:client_number].present?
      oauth_drive_token.save
    else
      false
    end
  end
  

#
# Create functions
#


#
# Update functions
#


#
# Delete functions
#


  # Remove an oauth connection for a given user and provider
  def self.remove_oauth_connection_for(given_user, provider_number)
    oauth = OauthDriveToken.get_provider_for(given_user, provider_number)
    oauth.destroy if oauth.present?
  end


#
# General functions
#


protected


end
