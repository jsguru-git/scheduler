require 'test_helper'

class OauthDriveTokenTest < ActiveSupport::TestCase
  
  
  test "should check user relationship" do
    assert_not_nil oauth_drive_tokens(:oauth_drive_tokens_001).user
    assert_kind_of User, oauth_drive_tokens(:oauth_drive_tokens_001).user
  end
  
  
  test "should attempt to get a provide auth for a given user" do
    provider = OauthDriveToken.get_provider_for(users(:users_001), APP_CONFIG['oauth']['google']['provider_number'])
    assert_not_nil provider
    
    provider = OauthDriveToken.get_provider_for(users(:users_002), APP_CONFIG['oauth']['google']['provider_number'])
    assert_nil provider
  end
  
  
  test "should create a new entry if doesnt exist" do
    assert_no_difference 'OauthDriveToken.all.length' do
      OauthDriveToken.create_or_update( :user => users(:users_001), 
                                        :access_token => 'newtoken', 
                                        :refresh_token => 'refresh', 
                                        :client_number => oauth_drive_tokens(:oauth_drive_tokens_001).client_number, 
                                        :expires_at => (Time.now + 1.hour).to_s, 
                                        :provider_number => APP_CONFIG['oauth']['google']['provider_number'])
    end
    
    provider = OauthDriveToken.get_provider_for(users(:users_001), APP_CONFIG['oauth']['google']['provider_number'])
    
    assert_equal 'newtoken', provider.access_token
  end
  
  
  test "should update an exisitng entry if one already exists" do
    assert_difference 'OauthDriveToken.all.length', +1 do
      OauthDriveToken.create_or_update( :user => users(:users_002), 
                                        :access_token => 'newtoken', 
                                        :refresh_token => 'refresh', 
                                        :client_number => oauth_drive_tokens(:oauth_drive_tokens_001).client_number, 
                                        :expires_at => (Time.now + 1.hour).to_s, 
                                        :provider_number => APP_CONFIG['oauth']['google']['provider_number'])
    end
  end
  
  
  test "should remove ouath token for a given user and provider" do
    assert_difference 'OauthDriveToken.all.length', -1 do
      OauthDriveToken.remove_oauth_connection_for(users(:users_001), APP_CONFIG['oauth']['google']['provider_number'])
    end
  end
  
  
end
