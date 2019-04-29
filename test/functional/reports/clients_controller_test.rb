require 'test_helper'

class Reports::ClientsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end
  
  
  test "get p and l report" do
    get :profit_and_loss
    assert_not_nil assigns(:clients)
    assert_response :success
  end
  
  test '#profit_and_loss authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :profit_and_loss
      assert_response :success
    end
  end

  test '#profit_and_loss does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :profit_and_loss
      assert_redirected_to root_url
    end
  end
  
  test "get quote p and l report" do
    get :quote_profit_and_loss
    assert_not_nil assigns(:clients)
    assert_response :success
  end

  test '#quote_profit_and_loss authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :quote_profit_and_loss
      assert_response :success
    end
  end

  test '#quote_profit_and_loss does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :quote_profit_and_loss
      assert_redirected_to root_url
    end
  end
  
  test "get p and l report for client" do
    get :project_profit_and_loss, :id => timings(:one).project.client_id
    assert_not_nil assigns(:projects)
    assert_response :success
  end
  
  test '#project_profit_and_loss authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :project_profit_and_loss, :id => timings(:one).project.client_id
      assert_response :success
    end
  end

  test '#project_profit_and_loss does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :project_profit_and_loss, :id => timings(:one).project.client_id
      assert_redirected_to root_url
    end
  end
  
  test "get quote p and l report for client" do
    get :quote_project_profit_and_loss, :id => clients(:clients_001).id
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test '#quote_project_profit_and_loss authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :quote_project_profit_and_loss, :id => clients(:clients_001).id
      assert_response :success
    end
  end

  test '#quote_project_profit_and_loss does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :quote_project_profit_and_loss, :id => clients(:clients_001).id
      assert_redirected_to root_url
    end
  end
  
  
end
