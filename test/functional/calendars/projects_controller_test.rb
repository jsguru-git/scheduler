require 'test_helper'

class Calendars::ProjectsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
  end

  test '#index should get project list' do
    get :index, :format => 'json'
    assert_not_nil assigns(:projects)

    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :format => 'json'
    assert_not_nil assigns(:projects)
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :format => 'json'
      assert_not_nil assigns(:projects)
    end
  end
    
  test '#recent should get list of open projects' do
    get :recent, :format => 'json', :user_id => users(:users_001)
    
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test '#recent authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :recent, :format => 'json', :user_id => users(:users_001)
      assert_not_nil assigns(:projects)
      assert_response :success
    end
  end

  test '#recent does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :recent, :format => 'json', :user_id => users(:users_001)
      assert_not_nil assigns(:projects)
      assert_redirected_to root_url
    end
  end
      
end
