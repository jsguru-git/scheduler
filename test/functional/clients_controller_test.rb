require 'test_helper'

class ClientsControllerTest < ActionController::TestCase


  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder]
  end

  # New
  test "get new form" do
    get :new
    assert_not_nil assigns(:client)
    assert_response :success
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

  # Create
  test "post to create" do
    assert_difference 'Client.all.length', +1 do
      post :create, :client => {:name => 'client name'}
      assert_response :redirect
    end
  end

  test "post to create and fail" do
    assert_no_difference 'Client.all.length' do
      post :create, :client => {:name => ''}
      assert_response :success
    end
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :client => {:name => 'client name'}
      assert_redirected_to client_path(Client.last)
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :client => {:name => 'client name'}
      assert_redirected_to root_url
    end
  end

  # Index
  test "should list all clients" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clients)
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

  # Edit
  test "should get edit form" do
    get :edit, :id => accounts(:accounts_001).clients.first.id
    assert_response :success
    assert_not_nil assigns(:client)
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).clients.first.id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).clients.first.id
      assert_redirected_to root_url
    end
  end

  # Update
  test "should update a client" do
    assert_no_difference 'Client.all.length' do
      put :update, :id => accounts(:accounts_001).clients.first.id, :client => {:name => 'WV'}
      assert_equal 'WV', assigns(:client).name
      assert_response :redirect
    end
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).clients.first.id, :client => {:name => 'WV'}
      assert_redirected_to client_path(accounts(:accounts_001).clients.first.id)
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).clients.first.id, :client => {:name => 'WV'}
      assert_redirected_to root_url
    end
  end

  # Archive
  test "should archive client" do
    put :archive, :id => clients(:clients_001).id
    assert assigns(:client).archived
  end

  test '#archive authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :archive, :id => clients(:clients_001).id
      assert_redirected_to client_path(clients(:clients_001).id)
    end
  end

  test '#archive does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :archive, :id => clients(:clients_001).id
      assert_redirected_to root_url
    end
  end

  # Activate
  test "should un-archive client" do
    put :activate, :id => clients(:clients_003).id
    assert_equal false, assigns(:client).archived
  end

  test '#activate authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :activate, :id => clients(:clients_003).id
      assert_redirected_to client_path(clients(:clients_003).id)
    end
  end

  test '#activate does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :activate, :id => clients(:clients_003).id
      assert_redirected_to root_url
    end
  end
  
  # Show
  test "should show a client" do
    get :show, :id => accounts(:accounts_001).clients.first.id
    assert_response :success
    assert_not_nil assigns(:client)
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, :id => accounts(:accounts_001).clients.first.id
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, :id => accounts(:accounts_001).clients.first.id
      assert_redirected_to root_url
    end
  end
  
end
