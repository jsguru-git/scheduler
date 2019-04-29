require 'test_helper'

class TrackApi::TasksControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader]
  end

	test "should get project list" do 
		get :index, :format => 'json', :project_id => projects(:projects_002).id
		assert_not_nil assigns(:project)
		assert_not_nil assigns(:tasks)

		assert_response :success
	end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, format: :json, project_id: create(:project).id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, format: :json, project_id: create(:project).id
      assert_redirected_to root_url
    end
  end
    
end
