require 'test_helper'

class TeamApi::TeamsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @request.env['HTTPS'] = 'on'
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder]
  end

  test '#show assigns the correct team' do
    get :show, id: 1, format: :json
    assert_equal 'Team James', assigns(:team).name
  end

  test '#show responds successfully if @team exists' do
    get :show, id: 1, format: :json
    assert_response :success
  end

  test '#show returns 404 if team does not exist' do
    get :show, id: 123456789, format: :json
    assert_response 404
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, id: 1, format: :json
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, id: 1, format: :json
      assert_redirected_to root_url
    end
  end

  test '#update assigns the correct team to @team' do
    get :update, id: 1, format: :json
    assert_equal 'Team James', assigns(:team).name
  end

  test '#update removes all users from a team' do
    get :update, id: 1, format: :json, users: []
    assert_response :success
  end

  test '#update adds users to a team' do
    put :update, id: 1, format: :json, users: [{ id: 5 }]
    assert_response :success
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :update, id: 1, format: :json
      assert_response :success
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :update, id: 1, format: :json
      assert_redirected_to root_url
    end
  end

  test '#create should assigns a new team with account_id to @team' do
    post :create
    assert_equal 1, assigns(:team).account_id
  end

  test '#create should return 422 if failed validation' do
    post :create, format: :json
    assert_response :unprocessable_entity
  end

  test '#create should create a new team successfully' do
    post :create, format: :json, team: { name: 'Example' }
    assert_response :success
  end

  test '#create should accept a hash of users to add to the team' do
    post :create, format: :json, team: { name: 'Example' },
                                 users: [{ id: 1 }, { id: 5 }]
    assert_response :success
  end

  test '#create should not allow the same user to be added to the same team twice' do
    post :create, format: :json, team: { name: 'Example' },
                                 users: [{ id: 1 }, { id: 1 }]
    assert_response :unprocessable_entity
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, format: :json, team: { name: 'Example' }
      assert_response :success
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, format: :json
      assert_redirected_to root_url
    end
  end


end