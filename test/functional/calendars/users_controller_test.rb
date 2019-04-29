require 'test_helper'

class Calendars::UsersControllerTest < ActionController::TestCase
    

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
  end

  test "should get all users for an account" do 
    get :index, :format => 'json'
    assert_not_nil assigns(:users)
    
    for user in assigns(:users)
      assert_equal accounts(:accounts_001).id, user.account_id
    end

    assert_response :success
  end
  
  test "should get all users for a given team" do 
    team = accounts(:accounts_001).teams.first
    get :index, :format => 'json', :team_id => team.id
    assert_not_nil assigns(:users)
    
    for user in assigns(:users)
      assert team.users.include? user
    end
    assert_response :success
  end
  

  test "should get all users for a given project" do 
    project = accounts(:accounts_001).projects.first
    get :index, :format => 'json', :project_id => project.id
    assert_not_nil assigns(:users)
    
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :format => 'json'
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :format => 'json'
      assert_redirected_to root_url
    end
  end
    
  test "should show json for a user" do
    get :show, :format => 'json', :id => accounts(:accounts_001).users.first.id

    assert_not_nil assigns(:user)
    assert_response :success
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, :format => 'json', :id => accounts(:accounts_001).users.first.id
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, :format => 'json', :id => accounts(:accounts_001).users.first.id
      assert_redirected_to root_url
    end
  end
    
    
end
