require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_general = [:account_holder, :administrator]
    @permitted_destroy = [:account_holder]
  end
  
  # Index
  test "should show documents index" do
    get :index, :project_id => projects(:projects_001).id
    
    assert_not_nil assigns(:documents)
    assert_not_nil assigns(:google_storage)
    assert_not_nil assigns(:dropbox_storage)
    assert_response :success
  end
  
  test '#index authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_001).id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  # Show
  test '#show authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      get :show, :project_id => projects(:projects_001).id, :id => documents(:documents_001).id
      assert_redirected_to assigns(:document).attachment.expiring_url(60, 'original')
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      get :show, :project_id => projects(:projects_001).id, :id => documents(:documents_001).id
      assert_redirected_to root_url
    end
  end
  
  # Destroy
  test "should remove attached document" do
    assert_difference 'Document.all.length',-1 do
      assert_difference 'DocumentComment.all.length', -2 do
        delete :destroy, :project_id => projects(:projects_001).id, :id => documents(:documents_001).id
      end
    end
  end

  test '#destroy authorizes permitted' do
    @permitted_destroy.each do |role|
      login_as_role role
      document = projects(:projects_001).documents.first
      delete :destroy, :project_id => projects(:projects_001).id, :id => document.id
      assert_redirected_to project_documents_path(projects(:projects_001).id)
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_destroy).each do |role|
      login_as_role role
      delete :destroy, :project_id => projects(:projects_001).id, :id => documents(:documents_001).id
      assert_redirected_to root_url
    end
  end
  
  # Switch
  test "should switch google provider account" do
    assert_difference 'OauthDriveToken.all.length', -1 do
      get :switch, :project_id => projects(:projects_001).id, :provider => 'google'
    end
    
    assert_response :redirect
  end

  test '#switch authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      get :switch, :project_id => projects(:projects_001).id, :provider => 'google'
      assert_redirected_to assigns(:storage).get_oauth_authorization_link(assigns(:account), assigns(:project))
    end
  end

  test '#switch does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      get :switch, :project_id => projects(:projects_001).id, :provider => 'google'
      assert_redirected_to root_url
    end
  end
  
  # new_upload
  test "should get new upload form" do
    get :new_upload, :project_id => projects(:projects_001).id
    
    assert_not_nil assigns(:document)
    assert_response :success
  end

  test '#new_upload authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      get :new_upload, :project_id => projects(:projects_001).id
      assert_response :success
    end
  end

  test '#new_upload does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      get :new_upload, :project_id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  # save_upload
  test '#save_upload authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      post :save_upload, { project_id: projects(:projects_001).id }
      assert_response :success
    end
  end

  test '#save_upload does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      post :save_upload, { project_id: projects(:projects_001).id }
      assert_redirected_to root_url
    end
  end
  
  # FIXME: Unable to stub required elements
  # new
  # test '#new authorizes permitted' do    
  #   CloudStorage::Base.stubs(:start).returns(CloudStorage::Base.start(:dropbox, users(:users_001)))

  #   CloudStorage::DropboxProvider.any_instance.stubs(:authorize!).returns(true)
  #   @permitted_general.each do |role|
  #     login_as_role role
  #     get :new, { project_id: projects(:projects_001).id }
  #     assert_response :success
  #   end
  # end

  # test '#new does not allow excluded' do
  #   Document.stubs(:attach_from_provider).returns({ docs: '123' })
  #   (roles - @permitted_general).each do |role|
  #     login_as_role role
  #     get :new, { project_id: projects(:projects_001).id }
  #     assert_redirected_to root_url
  #   end
  # end

  # create
  test '#create authorizes permitted' do
    Document.stubs(:attach_from_provider).returns({ docs: '123' })
    @permitted_general.each do |role|
      login_as_role role
      post :create, { project_id: projects(:projects_001).id }
      assert_redirected_to project_documents_path(projects(:projects_001))
    end
  end

  test '#create does not allow excluded' do
    Document.stubs(:attach_from_provider).returns({ docs: '123' })
    (roles - @permitted_general).each do |role|
      login_as_role role
      post :create, { project_id: projects(:projects_001).id }
      assert_redirected_to root_url
    end
  end
end
