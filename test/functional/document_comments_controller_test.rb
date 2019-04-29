require 'test_helper'

class DocumentCommentsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_general = [:account_holder, :administrator, :leader]
    @permitted_update = [:account_holder]
  end
  
  # Create
  test "should create new document comment" do
    assert_difference 'DocumentComment.all.length', +1 do
      post :create, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :document_comment => {:comment => 'my comment'}
    end
    
    assert_not_nil assigns(:document_comment)
    assert_response :redirect
  end
  
  
  test "should create new document comment but fail due to validaiton" do
    assert_no_difference 'DocumentComment.all.length' do
      post :create, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :document_comment => {:comment => ''}
    end
    
    assert_not_nil assigns(:document_comment)
    assert_response :redirect
  end

  test '#create authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      post :create, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :document_comment => {:comment => 'my comment'}
      assert_redirected_to project_documents_path(documents(:documents_001).project)
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      post :create, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :document_comment => {:comment => 'my comment'}
      assert_redirected_to root_url
    end
  end
  
  # Edit
  test "should get edit form" do
    get :edit, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
    
    assert_not_nil assigns(:document_comment)
  end

  test '#edit authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      get :edit, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      get :edit, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_redirected_to root_url
    end
  end
  
  # Update?
  test "should update document comment" do
    assert_no_difference 'DocumentComment.all.length' do
      put :update, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id, :document_comment => {:comment => 'my comment'}
    end
    
    assert_not_nil assigns(:document_comment)
    assert_response :redirect
  end
  
  test "should update document comment but fail due to validation" do
    assert_no_difference 'DocumentComment.all.length' do
      put :update, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id, :document_comment => {:comment => ''}
    end
    
    assert_not_nil assigns(:document_comment)
    assert_response :success
  end

  test '#update authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      put :update, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id, :document_comment => {:comment => 'my comment'}
      assert_redirected_to project_documents_path(documents(:documents_001).project)
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      put :update, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id, :document_comment => {:comment => 'my comment'}
      assert_redirected_to root_url
    end
  end
  
  # Destroy
  test "should remove document comment" do
    assert_difference 'DocumentComment.all.length', -1 do
      delete :destroy, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
    end
    assert_response :redirect
  end

  test "should remove document comment but fail as not an admin or the comment creater" do
    login_as(:users_005)
    
    assert_no_difference 'DocumentComment.all.length' do
      delete :destroy, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
    end
    assert_response :redirect
  end
  
  test '#destroy authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      delete :destroy, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_redirected_to project_documents_path(documents(:documents_001).project)
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      delete :destroy, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_redirected_to root_url
    end
  end

  # Cancel
  test "should cancel editing a document and return to list" do
    get :cancel, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
    assert_response :redirect
  end

  test '#cancel authorizes permitted' do
    @permitted_general.each do |role|
      login_as_role role
      get :cancel, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_redirected_to project_documents_path(documents(:documents_001).project)
    end
  end

  test '#cancel does not allow excluded' do
    (roles - @permitted_general).each do |role|
      login_as_role role
      get :cancel, :project_id => documents(:documents_001).project_id, :document_id => documents(:documents_001).id, :id => document_comments(:document_comments_001).id
      assert_redirected_to root_url
    end
  end

end
