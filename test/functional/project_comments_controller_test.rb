require 'test_helper'

class ProjectCommentsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_general = [:account_holder, :administrator, :leader]
    @permitted_create = [:account_holder, :administrator]
    @permitted_update = [:account_holder]
  end
  
  test "should create new comment" do
    assert_difference 'ProjectComment.all.length', +1 do
      post :create, :project_id => projects(:projects_001).id, :project_comment => {:comment => 'my comment'}
    end
    
    assert_not_nil assigns(:project_comment)
    assert_response :redirect
  end

  test "should create new document comment but fail due to validaiton" do
    assert_no_difference 'ProjectComment.all.length' do
      post :create, :project_id => projects(:projects_001).id, :project_comment => {:comment => ''}
    end
  
    assert_not_nil assigns(:project_comment)
    assert_response :redirect
  end

  test '#create authorizes permitted' do
    @permitted_create.each do |role|
      login_as_role role
      post :create, :project_id => projects(:projects_001).id, :project_comment => {:comment => 'my comment'}
      assert_redirected_to project_project_comments_path(projects(:projects_001))
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_create).each do |role|
      login_as_role role
      post :create, :project_id => projects(:projects_001).id, :project_comment => {:comment => 'my comment'}
      assert_redirected_to root_url
    end
  end

  test "should get edit form" do
    get :edit, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
  
    assert_not_nil assigns(:project_comment)
  end

  test '#edit authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      get :edit, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      get :edit, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_redirected_to root_url
    end
  end
  
  test "should update comment" do
    assert_no_difference 'ProjectComment.all.length' do
      put :update, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id, :project_comment => {:comment => 'my comment'}
    end
    
    assert_not_nil assigns(:project_comment)
    assert_response :redirect
  end

  test '#update authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      put :update, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id, :project_comment => {:comment => 'my comment'}
      assert_redirected_to project_project_comments_path(projects(:projects_001))
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      put :update, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id, :project_comment => {:comment => 'my comment'}
      assert_redirected_to root_url
    end
  end
    
  test "should update comment but fail due to validation" do
    assert_no_difference 'ProjectComment.all.length' do
      put :update, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id, :project_comment => {:comment => ''}
    end
    
    assert_not_nil assigns(:project_comment)
    assert_response :success
  end
  
  
  test "should remove comment" do
    assert_difference 'ProjectComment.all.length', -1 do
      delete :destroy, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
    end
    assert_response :redirect
  end
  
  
  test "should remove comment but fail as not an admin or the comment creater" do
    login_as(:users_005)
    
    assert_no_difference 'ProjectComment.all.length' do
      delete :destroy, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
    end
    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      delete :destroy, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_redirected_to project_project_comments_path(projects(:projects_001))
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      delete :destroy, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_redirected_to root_url
    end
  end

  test "should cancel editing a comment and return to list" do
    get :cancel, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
  
    assert_response :redirect
  end

  test '#cancel authorizes permitted' do
    [:account_holder, :administrator].each do |role|
      login_as_role role
      get :cancel, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_redirected_to project_project_comments_path(projects(:projects_001))
    end
  end

  test '#cancel does not allow excluded' do
    [:member, :leader].each do |role|
      login_as_role role
      get :cancel, :project_id => projects(:projects_001).id, :id => project_comments(:project_comments_001).id
      assert_redirected_to root_url
    end
  end

  test "should get reply form" do
    get :reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id
    
    assert_not_nil assigns(:project_comment)
    assert_not_nil assigns(:new_project_comment)
    assert_response :success
  end

  test '#reply authorizes permitted' do
    @permitted_create.each do |role|
      login_as_role role
      get :reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id
      assert_response :success
    end
  end

  test '#reply does not allow excluded' do
    (roles - @permitted_create).each do |role|
      login_as_role role
      get :reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id
      assert_redirected_to root_url
    end
  end
  
  test "should post reply to an existing comment" do
    assert_difference 'ProjectComment.all.length', +1 do
      post :submit_reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id, :project_comment => {:project_comment_id => project_comments(:project_comments_001).id, :comment => 'my comment'}
    end
    
    assert_not_nil assigns(:project_comment)
    assert_not_nil assigns(:new_project_comment)
    assert_response :redirect
  end
  
  test '#submit_reply authorizes permitted' do
    @permitted_create.each do |role|
      login_as_role role
      post :submit_reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id, :project_comment => {:project_comment_id => project_comments(:project_comments_001).id, :comment => 'my comment'}
      assert_redirected_to project_project_comments_path(projects(:projects_001))
    end
  end

  test '#submit_reply does not allow excluded' do
    (roles - @permitted_create).each do |role|
      login_as_role role
      post :submit_reply, :project_id => project_comments(:project_comments_001).project_id, :id => project_comments(:project_comments_001).id, :project_comment => {:project_comment_id => project_comments(:project_comments_001).id, :comment => 'my comment'}
      assert_redirected_to root_url
    end
  end
end
