require 'test_helper'

class Reports::PagesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end
  
  test "should show report list" do
    get :index
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index
      assert_redirected_to root_url
    end
  end
  
  test "should show project choice form" do
    get :select_project, format: :js, path: invoice_project_invoice_usages_path(0)
    
    assert_response :success
  end

  test "should get project list based on client" do
    get :select_project, format: :js, client_id: clients(:clients_001).id
    
    assert_response :success
  end

  test '#select_project authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :select_project, format: :js, path: invoice_project_invoice_usages_path(0)
      assert_response :success
    end
  end

  test '#select_project does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :select_project, format: :js, path: invoice_project_invoice_usages_path(0)
      assert_redirected_to root_url
    end
  end

  test '#submit_select_project authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :submit_select_project, project_id: projects(:projects_001).id, path: invoice_project_invoice_usages_path(0)
      assert_redirected_to invoice_project_invoice_usages_path(projects(:projects_001).id)
    end
  end

  test '#submit_select_project does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :submit_select_project, project_id: projects(:projects_001).id, path: invoice_project_invoice_usages_path(0)
      assert_redirected_to root_url
    end
  end

  test '#update_project authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :update_project, format: :js
      assert_response :success
    end
  end

  test '#update_project does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :update_project, format: :js
      assert_redirected_to root_url
    end
  end

end
