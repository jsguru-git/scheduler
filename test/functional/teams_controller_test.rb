require 'test_helper'

class TeamsControllerTest < ActionController::TestCase

  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)

    @valid_parameters = {:name => 'Joe'}

    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder]
  end

  # Index
  test "should get index" do
    get :index
    assert_not_nil assigns(:teams)
    assert :success
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

  # New
  test "should get new form" do
    get :new
    assert_not_nil assigns(:team)
    assert :success
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new
      assert_redirected_to root_url
    end
  end

  # edit
  test "should get edit form" do
    get :edit, :id => accounts(:accounts_001).teams.first.id
    assert_not_nil assigns(:team)
    assert_response :success
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).teams.first.id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).teams.first.id
      assert_redirected_to root_url
    end
  end

  # Cancel
  test "should get cancel" do
    get :cancel
    assert :success
  end

  test '#cancel authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :cancel
      assert_redirected_to teams_path
    end
  end

  test '#cancel does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :cancel
      assert_redirected_to root_url
    end
  end

  # Destroy
  test "should delete user" do
    assert_difference 'Team.all.length', -1 do
      delete :destroy, :id => accounts(:accounts_001).teams.first.id
    end
    assert_redirected_to teams_path
  end

  test '#delete authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      delete :destroy, :id => accounts(:accounts_001).teams.first.id
      assert_redirected_to teams_path
    end
  end

  test '#delete does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :id => accounts(:accounts_001).teams.first.id
      assert_redirected_to root_url
    end
  end
end
