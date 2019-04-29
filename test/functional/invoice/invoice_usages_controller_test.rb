require 'test_helper'

class Invoice::InvoiceUsagesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end
  
  
  test "should get the list page" do
    get :index, :project_id => projects(:projects_015)
    
    assert_not_nil assigns(:invoices)
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_015)
      assert_not_nil assigns(:invoices)
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_015)
      assert_redirected_to root_url
    end
  end
  
  test "should get new form" do
    get :new, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id
    
    assert_not_nil assigns(:invoice_usage)
    assert_response :success
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id
    
      assert_not_nil assigns(:invoice_usage)
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id
      assert_redirected_to root_url
    end
  end
  
  
  test "should get edit form" do
    get :new, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id
    
    assert_not_nil assigns(:invoice_usage)
    assert_response :success
  end
  
  
  test "should create new usage" do
    assert_difference 'InvoiceUsage.all.length', +1 do
      post :create, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :invoice_usage => {:name => 'Dev', :amount => '2.00'}
      assert_response :redirect
    end
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'InvoiceUsage.all.length', +1 do
        post :create, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :invoice_usage => {:name => 'Dev', :amount => '2.00'}
        assert_response :redirect
      end
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :invoice_usage => {:name => 'Dev', :amount => '2.00'}
      assert_redirected_to root_url
    end
  end
  
  test "should create new usage but fail due to validation" do
    assert_no_difference 'InvoiceUsage.all.length' do
      post :create, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :invoice_usage => {:name => '', :amount => '2.00'}
      assert_response :success
    end
  end
  
  
  test "should update usage" do
    put :update, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id, :invoice_usage => {:amount => '2.00'}
    assert_response :redirect
    
    invoice_usages(:one).reload
    assert_equal 200, invoice_usages(:one).amount_cents
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id, :invoice_usage => {:amount => '2.00'}
      assert_response :redirect
      
      invoice_usages(:one).reload
      assert_equal 200, invoice_usages(:one).amount_cents
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id, :invoice_usage => {:amount => '2.00'}
      assert_redirected_to root_url
    end
  end

  test "should update usage but fail due to validation" do
    put :update, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id, :invoice_usage => {:name => ''}
    assert_response :success
  end
  
  
  test "should remove usage" do
    assert_difference 'InvoiceUsage.all.length', -1 do
      delete :destroy, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id
      assert_response :redirect
    end
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'InvoiceUsage.all.length', -1 do
        delete :destroy, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id
        assert_response :redirect
      end
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :project_id => projects(:projects_015), :invoice_id => invoices(:invoices_002).id, :id => invoice_usages(:one).id
      assert_redirected_to root_url
    end
  end
  
end
