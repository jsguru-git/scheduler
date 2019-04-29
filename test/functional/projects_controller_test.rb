require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase


  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_update = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end

  #
  # index
  test "should get project list" do
    get :index
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index
      assert_redirected_to root_url
    end
  end

  #
  # New
  test "should get new project form" do
    get :new
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new
      assert_redirected_to root_url
    end
  end

  #
  # Create
  test "should post new project" do
    assert_difference 'Project.all.length', +1 do
      post :create, :project => {:name => 'new project name', :description => 'description here'}
    end
    assert_not_nil assigns(:project)
    assert_response :redirect
  end

  test "should post new project but fail validation" do
    assert_no_difference 'Project.all.length' do
      post :create, :project => {:description => 'description here'}
    end

    assert_not_nil assigns(:project)
    assert_response :success
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :project => {:name => 'new project name', :description => 'description here'}
      assert_redirected_to project_path(assigns(:project))
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project => {:name => 'new project name', :description => 'description here'}
      assert_redirected_to root_url
    end
  end

  #
  # Show
  test "show get project overview" do
    get :show, :id => accounts(:accounts_001).projects.first.id
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, :id => accounts(:accounts_001).projects.first.id
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, :id => accounts(:accounts_001).projects.first.id
      assert_redirected_to root_url
    end
  end

  #
  # Schedule
  test "should get project schedule" do
    get :schedule, :id => projects(:projects_001).id #accounts(:accounts_001).projects.first.id
    assert_not_nil assigns(:project)
    assert_response :success
  end


  #
  # Schedule
  test "should get project schedule but not active" do
    change_host_to(:accounts_002)
    login_as(:users_002)

    assert_raise ActiveRecord::RecordNotFound do
      get :schedule, :id => accounts(:accounts_002).projects.first.id
    end
  end


  #
  # Track
  test "should get project track" do
    get :track, :id => accounts(:accounts_001).projects.first.id
    assert_not_nil assigns(:project)
    assert_response :success
  end


  #
  # Track
  test "should get project track but not active" do
    change_host_to(:accounts_002)
    login_as(:users_002)

    assert_raise ActiveRecord::RecordNotFound do
      get :track, :id => accounts(:accounts_002).projects.first.id
    end
  end

  #
  # Edit
  test "should edit project" do
    get :edit, :id => projects(:projects_001).id
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test '#edit authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      get :edit, :id => projects(:projects_001).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      get :edit, :id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  #
  # Update
  test "should update project" do
    put :update, :id => projects(:projects_001).id, :project => {:description => 'description here2'}

    assert 'description here2', assigns(:project).description
    assert_not_nil assigns(:project)
    assert_response :redirect
  end

  test '#update authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      put :update, :id => projects(:projects_001).id, :project => {:description => 'description here2'}
      assert_redirected_to project_path(projects(:projects_001))
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      put :update, :id => projects(:projects_001).id, :project => {:description => 'description here2'}
      assert_redirected_to root_url
    end
  end

  #
  # archive
  test "should archive project" do
    put :archive, :id => projects(:projects_001).id

    assert_not_nil assigns(:project)
    assert_equal true, assigns(:project).archived
    assert_response :redirect
  end

  test '#archive authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      put :archive, :id => projects(:projects_001).id
      assert_redirected_to project_path(projects(:projects_001))
    end
  end

  test '#archive does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      put :archive, :id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  #
  # re-activate
  test "should re-activate project" do
    project = projects(:projects_001)
    project.archived = false
    project.save!

    put :activate, :id => project.id

    assert_not_nil assigns(:project)
    assert_equal false, assigns(:project).archived
    assert_response :redirect
  end

  test '#activate authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      put :activate, :id => projects(:projects_001).id
      assert_redirected_to project_path(projects(:projects_001))
    end
  end

  test '#activate does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      put :activate, :id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  #
  # Edit
  test "should not be able to edit common task project" do
    assert_raise ActiveRecord::RecordNotFound do
      get :edit, :id => accounts(:accounts_001).account_setting.common_project_id
    end
  end
  
  # edit_percentage_complete
  test "should get edit percentage complete page" do
    get :edit_percentage_complete, :id => projects(:projects_001).id, :format => 'js'
    
    assert_not_nil assigns(:project)
    assert_response :success
  end
  
  test "should get edit percentage complete page for non js user" do
    get :edit_percentage_complete, :id => projects(:projects_001).id

    assert_response :redirect
  end 
  
  test "should update percentage complete" do
    get :update_percentage_complete, :id => projects(:projects_001).id, :format => 'js', :project => {:percentage_complete => 50}
    
    assert_equal 50, assigns(:project).percentage_complete
    assert_response :success
  end

  test '#edit_percentage_complete authorizes permitted' do
    @permitted_update.each do |role|
      login_as_role role
      get :update_percentage_complete, :id => projects(:projects_001).id, :format => 'js', :project => { :percentage_complete => 50 }
      assert_response :success
    end
  end

  test '#edit_percentage_complete does not allow excluded' do
    (roles - @permitted_update).each do |role|
      login_as_role role
      get :update_percentage_complete, :id => projects(:projects_001).id, :format => 'js', :project => { :percentage_complete => 50 }
      assert_redirected_to root_url
    end
  end
  

end
