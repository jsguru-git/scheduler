require 'test_helper'

class CloudStorage::CloudStorageGoogleTest < ActiveSupport::TestCase
  
  
  # Mock dropbox wrapper
  def setup
    # Authentication mock
    Signet::OAuth2::Client.any_instance.stubs(:fetch_access_token!)
    Signet::OAuth2::Client.any_instance.stubs(:access_token).returns('this_is_a_code')
    Signet::OAuth2::Client.any_instance.stubs(:refresh_token).returns('12asdfsadf34')
    Signet::OAuth2::Client.any_instance.stubs(:client_id).returns('12345')
    Signet::OAuth2::Client.any_instance.stubs(:expires_in).returns(5665)
    
    # Discover api mock
    files = stub(:list => 'drive.files.list', :get => 'drive.files.get')
    about = stub(:get => 'drive.about.get')
    drive = stub(:files => files, :about => about)
    Google::APIClient.any_instance.stubs(:discovered_api).returns(drive)
  end


  test 'should create a new instance' do
    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    
    assert_not_nil google_storage
  end
  
  
  test 'should check if authorized when have oAuth token' do
    CloudStorage::GoogleProvider.any_instance.stubs(:current_token_still_valid?).returns(true)
    
    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    
    assert google_storage.is_authorized?
  end
  
  
  test 'should check if authorized when dont have oAuth token' do
    google_storage = CloudStorage::Base.start(:google, users(:users_007))
    
    assert_equal false, google_storage.is_authorized?
  end
  
  
  test 'should get oauth authenticaiton link' do
    google_storage = CloudStorage::Base.start(:google, users(:users_007))
    link = google_storage.get_oauth_authorization_link(accounts(:accounts_001), projects(:projects_001))
    
    assert link.include?('https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force')
  end
  
  
  test 'should get token from authorization code for new auth user' do
    google_storage = CloudStorage::Base.start(:google, users(:users_007))
    
    assert_difference 'OauthDriveToken.count', +1 do
      assert google_storage.get_oauth_token('this_is_a_code', users(:users_007))
    end
  end
  
  
  test 'should get token from authorization code for existing auth user' do
    CloudStorage::GoogleProvider.any_instance.stubs(:current_token_still_valid?).returns(true)

    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    
    assert_no_difference 'OauthDriveToken.count' do
      assert google_storage.get_oauth_token('this_is_a_code', users(:users_001))
    end
  end
  
  
  test 'should get directory listing' do
    CloudStorage::GoogleProvider.any_instance.stubs(:get_parent_folder_id).returns('4354')
    
    result = stub(:id => 1, :title => 'test', :alternateLink => 'http://www.link.com', :ownerNames => nil, :createdDate => Time.now, :mimeType => 'application/vnd.google-apps.drawing')
    files = stub(:items => [result])
    list_result = stub(:data => files, :error? => false, :status => 200)
    Google::APIClient.any_instance.stubs(:execute).returns(list_result)
    

    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    result = google_storage.get_directory_listing_for({:folder_id => '37465'})
    
    assert_not_nil result[:results]
    assert_equal 'application/vnd.google-apps.drawing', result[:results].first[:mime_type]
    assert_equal 'image', result[:results].first[:file_type]
    assert_equal '4354', result[:parent_folder_id]
  end
  
  
  test 'should search available files' do
    result = stub(:id => 1, :title => 'test', :alternateLink => 'http://www.link.com', :ownerNames => nil, :createdDate => Time.now, :mimeType => 'application/vnd.google-apps.drawing')
    files = stub(:items => [result])
    list_result = stub(:data => files, :error? => false, :status => 200)
    Google::APIClient.any_instance.stubs(:execute).returns(list_result)
    

    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    result = google_storage.search_files({:term => 'test termn'})
    
    assert_not_nil result[:results]
    assert_equal 'application/vnd.google-apps.drawing', result[:results].first[:mime_type]
    assert_equal 'image', result[:results].first[:file_type]
  end
  
  
  test 'should get file details' do
    result = stub(:id => 1, :title => 'test', :alternateLink => 'http://www.link.com', :ownerNames => nil, :createdDate => Time.now, :mimeType => 'application/vnd.google-apps.drawing')
    result = stub(:data => result, :error? => false, :status => 200)
    Google::APIClient.any_instance.stubs(:execute).returns(result)
    
    google_storage = CloudStorage::Base.start(:google, users(:users_001))
    result = google_storage.get_file_details('37465')
    
    assert_not_nil result
    assert_equal 'application/vnd.google-apps.drawing', result[:mime_type]
    assert_equal 'image', result[:file_type]
  end
  
  
end

