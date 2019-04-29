require 'test_helper'

class Quote::ProjectsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader]
  end
  
  
  #
  # index
  test "should get quote project list" do 
  	get :index
  	assert assigns(:projects)
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
      get :index, :project_id => accounts(:accounts_001).projects.first.id
      assert_redirected_to root_url
    end
  end
  
  #
  # quotes
  test "should search quotes" do 
  	get :search
  	assert assigns(:quotes)
  	assert_response :success
  end

    test '#search authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :search
      assert_response :success
    end
  end

  test '#search does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :search
      assert_redirected_to root_url
    end
  end
  
  
end
