require 'test_helper'

class TrackApi::ProjectsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder, :administrator]
  end

  test "should get project list" do
    get :index, :format => 'json'
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, format: :json
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, format: :json
      assert_redirected_to root_url
    end
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, format: :json, id: create(:project).id, project: { name: 'example' }
      assert_response :success
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, format: :json, id: create(:project).id, project: { name: 'example' }
      assert_redirected_to root_url
    end
  end
    
    
end
