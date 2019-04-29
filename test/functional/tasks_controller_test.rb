require 'test_helper'

class TasksControllerTest < ActionController::TestCase


  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader]
    @permitted_write = [:account_holder]
  end


  test "should get task index" do
    get :index, :project_id => accounts(:accounts_001).projects.first.id
    assert :success
    assert_not_nil assigns(:project)
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :project_id => accounts(:accounts_001).projects.first.id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :project_id => accounts(:accounts_001).projects.first.id
      assert_redirected_to root_url
    end
  end

  # Show
  test "GET #show should return http success" do
    task = tasks(:tasks_017)
    get :show, project_id: task.project.id, id: task.id
    assert :success
    assert_not_nil assigns(:task)
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      task = tasks(:tasks_017)
      get :show, project_id: task.project.id, id: task.id
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      task = tasks(:tasks_017)
      get :show, project_id: task.project.id, id: task.id
      assert_redirected_to root_url
    end
  end

  # New
  test "should get new form" do

    get :new, :project_id => projects(:projects_001).id
    assert :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:project)
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_001).id
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  # Create
  test "should create new task" do
    assert_difference 'Task.all.size', +1 do
      post :create, :task => {:name => 'Another task'}, :project_id => projects(:projects_001).id #accounts(:accounts_001).projects.first.id
    end
    assert_not_nil flash[:notice].to_s
    assert_response :redirect
  end


  test "should create new task but fail" do
    assert_no_difference 'Task.all.size' do
      post :create, :task => {:name => ''}, :project_id => projects(:projects_001).id # accounts(:accounts_001).projects.first.id
    end
    assert_response :success
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :task => {:name => 'Another task'}, :project_id => projects(:projects_001).id
      assert_redirected_to project_tasks_path
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :task => {:name => 'Another task'}, :project_id => projects(:projects_001).id
      assert_redirected_to root_url
    end
  end

  # Cancel
  test "should cancel create" do
    get :cancel, :project_id => accounts(:accounts_001).projects.first.id
    assert_response :redirect
  end

  test '#cancel authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :cancel, :project_id => accounts(:accounts_001).projects.first.id
      assert_redirected_to project_tasks_path
    end
  end

  test '#cancel does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :cancel, :project_id => accounts(:accounts_001).projects.first.id
      assert_redirected_to root_url
    end
  end

  # Edit
  test "should get edit form" do
    get :edit, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id
    assert :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:project)
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :edit, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id
      assert_redirected_to root_url
    end
  end

  test "should update task" do
    assert_no_difference 'Task.all.size' do
      put :update, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id, :task => { :name => 'new name' }
    end
    assert_not_nil flash[:notice].to_s
    assert_response :redirect
  end

  test "should update task but fail" do
    assert_no_difference 'Task.all.size' do
      put :update, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id, :task => { :name => '' }
    end
    assert_response :success
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id, :task => { :name => 'new name' }
      assert_redirected_to project_tasks_path
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :project_id => tasks(:tasks_001).project.id, :id => tasks(:tasks_001).id, :task => { :name => 'new name' }
      assert_redirected_to root_url
    end
  end

  # Destroy
  test "should remove task" do
    assert_difference 'Task.all.size', -1 do
      delete :destroy, :project_id => tasks(:tasks_002).project_id, :id => tasks(:tasks_002).id
    end
    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      delete :destroy, :project_id => tasks(:tasks_002).project_id, :id => tasks(:tasks_002).id
      assert_redirected_to project_tasks_path
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :project_id => tasks(:tasks_002).project_id, :id => tasks(:tasks_002).id
      assert_redirected_to root_url
    end
  end
end
