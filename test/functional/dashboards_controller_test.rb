require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase


  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader, :member]
  end

  # Index
  test "get index" do
    get :index, nil, { :user_id => 1 }
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index, nil, { :user_id => 1 }
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index, nil, { :user_id => 1 }
      assert_redirected_to root_url
    end
  end
end
