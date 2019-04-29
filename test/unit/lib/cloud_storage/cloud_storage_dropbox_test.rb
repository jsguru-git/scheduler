require 'test_helper'

class CloudStorage::CloudStorageDropboxTest < ActiveSupport::TestCase
  
  
  # Mock dropbox wrapper
  def setup
    DropboxOAuth2Flow.any_instance.stubs(:finish).returns('myaccesstoken', 100, 'url_state')
    
    @json_metadata = {
        'size' => "225.4KB",
        'rev' => "35e97029684fe",
        'thumb_exists' => false,
        'bytes' => 230783,
        'modified' => Time.now,
        'client_mtime' => Time.now,
        'path' => "/test/Getting_Started.pdf",
        'is_dir' => false,
        'icon' => "page_white_acrobat",
        'root' => "dropbox",
        'mime_type' => "application/pdf",
        'revision' => 220823
    }
    
    @json_metadata_image = {
        'size' => "225.4KB",
        'rev' => "35e97029684fe",
        'thumb_exists' => false,
        'bytes' => 230783,
        'modified' => Time.now,
        'client_mtime' => Time.now,
        'path' => "/test/Getting_Started.png",
        'is_dir' => false,
        'icon' => "",
        'root' => "dropbox",
        'mime_type' => "image/png",
        'revision' => 220823
    }
  end


  test 'should create a new instance' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    
    assert_not_nil dropbox_storage
  end
  
  
  test 'should check if authorized when have oAuth token' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    
    assert dropbox_storage.is_authorized?
  end
  
  
  test 'should check if authorized when dont have oAuth token' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_002))
    
    assert_equal false, dropbox_storage.is_authorized?
  end
  
  
  test 'should get oauth authenticaiton link' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_002))
    link = dropbox_storage.get_oauth_authorization_link(accounts(:accounts_001), projects(:projects_001))
    
    assert link.include?('https://www.dropbox.com/1/oauth2/authorize?client_id=360exwg86fkznf9&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Foauth%2Fdrive_callbacks')
  end
  
  
  test 'should get token from authorization code for new auth user' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_002))
    
    assert_difference 'OauthDriveToken.count', +1 do
      assert dropbox_storage.get_oauth_token('this_is_a_code', users(:users_002), {:state => 'test'})
    end
  end
  
  
  test 'should get token from authorization code for existing auth user' do
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    
    assert_no_difference 'OauthDriveToken.count' do
      assert dropbox_storage.get_oauth_token('this_is_a_code', users(:users_001), {:state => 'test'})
    end
  end
  
  
  test 'should get directory listing' do
    DropboxClient.any_instance.stubs(:metadata).returns({'contents' => [@json_metadata]})
    
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    result = dropbox_storage.get_directory_listing_for({:folder_id => '/test/test/'})
    
    assert_not_nil result[:results]
    assert_equal @json_metadata['mime_type'], result[:results].first[:mime_type]
    assert_equal 'pdf', result[:results].first[:file_type]
    assert_equal '/test/', result[:parent_folder_id]
  end
  
  
  test 'should search available files' do
    DropboxClient.any_instance.stubs(:search).returns([@json_metadata])
    
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    result = dropbox_storage.search_files({:term => 'file'})
    
    assert_not_nil result[:results]
    assert_equal @json_metadata['mime_type'], result[:results].first[:mime_type]
    assert_equal 'pdf', result[:results].first[:file_type]
  end
  
  
  test 'should get file details' do
    DropboxClient.any_instance.stubs(:metadata).returns(@json_metadata_image)
    DropboxClient.any_instance.stubs(:shares).returns({'url' => 'http://dd.co/test'})
    
    dropbox_storage = CloudStorage::Base.start(:dropbox, users(:users_001))
    result = dropbox_storage.get_file_details("/test/Getting_Started.png")
    
    assert_not_nil result
    assert_equal @json_metadata_image['mime_type'], result[:mime_type]
    assert_equal 'image', result[:file_type]
  end
  
  
end

