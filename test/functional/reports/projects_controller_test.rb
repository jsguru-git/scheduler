require 'test_helper'

class Reports::ProjectsControllerTest < ActionController::TestCase
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end
  
  test "get overview report" do
    user = accounts(:accounts_001).users.first

    get :overview

    assert_not_nil assigns(:projects)
    assert_response :success
  end
  
  test "get overview report with project_id" do
    user = accounts(:accounts_001).users.first
    
    get :overview, :project_id => projects(:projects_002).id
  
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).length
    assert_response :success
  end

  test '#overview authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :overview
      assert_response :success
    end
  end

  test '#overview does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :overview
      assert_redirected_to root_url
    end
  end
  
  test "get overview report with client_id" do
    user = accounts(:accounts_001).users.first
    
    get :overview, :client_id => projects(:projects_014).client_id
  
    assert_not_nil assigns(:projects)
    assert_response :success
  end
  
  test "get percent of time used on project reprot" do
    get :percentage_time_spent
    
    assert_not_nil assigns(:teams)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test '#percentage_time_spent authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :percentage_time_spent
      assert_response :success
    end
  end

  test '#percentage_time_spent does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :percentage_time_spent
      assert_redirected_to root_url
    end
  end
  
  test "should get qa stats for a project" do 
    get :qa_stats, :id => projects(:projects_002).id
    
    assert_response :success
    assert_not_nil assigns(:project)
  end

  test '#qa_stats authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :qa_stats, :id => projects(:projects_002).id
      assert_response :success
    end
  end

  test '#qa_stats does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :qa_stats, :id => projects(:projects_002).id
      assert_redirected_to root_url
    end
  end

  test 'get delivery forecast' do
    get :forecast
    assert_response :success
  end

  test '#forecast authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :forecast
      assert_response :success
    end
  end

  test '#forecast does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :forecast
      assert_redirected_to root_url
    end
  end

  test 'get delivery forecast assigns projects' do
    get :forecast
    assert_not_nil assigns(:projects)
  end

  test 'get delivery forecast should only return in progress projects' do
    build(:project, project_status: 'opportunity')
    get :forecast
    statuses = assigns(:projects).map(&:project_status).uniq
    assert_equal ['in_progress'], statuses
  end

  test '#project_utilisation authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :project_utilisation
      assert_response :success
    end
  end

  test '#project_utilisation does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :project_utilisation
      assert_redirected_to root_url
    end
  end
  
end
