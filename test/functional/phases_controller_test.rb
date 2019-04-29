require 'test_helper'

class PhasesControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @request.env["HTTPS"] = 'on'
    @permitted = [:account_holder]
  end

  # Index
  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index, format: :json
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index, format: :json
      assert_redirected_to root_url
    end
  end

  # Show
  test '#show authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :show, { id: 1, format: :json }
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :show, { id: 1, format: :json }
      assert_redirected_to root_url
    end
  end

  # Create
  test '#create should create a new phase' do
    assert_difference 'Phase.all.count', +1 do
      post :create, name: 'test_phase', format: :json
    end
  end

  test '#create authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      post :create, name: 'test_phase', format: :json
      assert_response :success
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      post :create, name: 'test_phase', format: :json
      assert_redirected_to root_url
    end
  end

  # Destroy
  test '#destroy authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      delete :destroy, { id: 1, format: :json }
      assert_response :success
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      delete :destroy, { id: 1, format: :json }
      assert_redirected_to root_url
    end
  end
end
