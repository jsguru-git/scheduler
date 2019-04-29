require 'test_helper'

class Invoice::ProjectsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
  end
  
  
  #
  # index
  test "should get invoice project list" do 
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
      get :index
      assert_redirected_to root_url
    end
  end
  
  
end
