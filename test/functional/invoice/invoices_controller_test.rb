require 'test_helper'

class Invoice::InvoicesControllerTest < ActionController::TestCase
    
    
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @valid_params = {:address => 'Queen St', :invoice_date => '2013-04-15', :due_on_date => '2013-05-15', :invoice_number => 876, :terms => '30 days', :po_number => '7654', :pre_payment => false, :currency => 'gbp', :vat_rate => 20, :invoice_items_attributes => [{:name => 'item name', :quantity => 1, :vat => true, :amount => 100.00}] }
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end
    
  
  test "should only provide acccess if invocie is active" do
    account_account_components(:four).destroy
    
    assert_raises ActiveRecord::RecordNotFound do
      get :index, :project_id => projects(:projects_002)
    end
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_002)
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :project_id => projects(:projects_002)
      assert_redirected_to root_url
    end
  end
  
  
  test "should show a list of all created invoiced" do
    get :index, :project_id => projects(:projects_002)
    assert_response :success
  end
  
  
  test "should show invoice" do
    get :show, :project_id => projects(:projects_002), :id => invoices(:invoices_001)
    assert_not_nil assigns(:invoice)
    assert_response :success
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, :project_id => projects(:projects_002), :id => invoices(:invoices_001)
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, :project_id => projects(:projects_002), :id => invoices(:invoices_001)
      assert_redirected_to root_url
    end
  end
  
  test "should display new invoice form" do
    get :new, :project_id => projects(:projects_002)
    assert_not_nil assigns(:invoice)
    assert_response :success
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_002)
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, :project_id => projects(:projects_002)
      assert_redirected_to root_url
    end
  end
  
  test "should create new invoice" do
    assert_difference 'Invoice.all.length', +1 do
      post :create, :project_id => projects(:projects_002), :invoice => @valid_params
      assert_response :redirect
    end
  end
  
  test "should create new invoice and set user id" do
    assert_difference 'Invoice.all.length', +1 do
      post :create, :project_id => projects(:projects_002), :invoice => @valid_params
      assert_equal users(:users_001).id, assigns(:invoice).user_id
      assert_response :redirect
    end
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :project_id => projects(:projects_002), :invoice => @valid_params
      assert_equal users(:users_001).id, assigns(:invoice).user_id
      assert_response :redirect
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project_id => projects(:projects_002), :invoice => @valid_params
      assert_redirected_to root_url
    end
  end
  
  test "should create new invoice but fail due to validation" do
    assert_no_difference 'Invoice.all.length' do
      post :create, :project_id => projects(:projects_002), :invoice => @valid_params.merge!(:invoice_number => nil)
      assert_response :success
      assert assigns(:invoice).errors[:invoice_number].present?
    end
  end
  
  
  test "should add addiitoanl blank invoice item" do
    get :add_blank_item, :project_id => projects(:projects_002), :format => 'js'
    assert_response :success
  end

  test '#add_blank_item authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :add_blank_item, :project_id => projects(:projects_002), :format => 'js'
      assert_response :success
    end
  end

  test '#add_blank_item does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :add_blank_item, :project_id => projects(:projects_002), :format => 'js'
      assert_redirected_to root_url
    end
  end
  
  test "should show all payment profiles yet to be invoiced for project" do
    get :add_payment_profile, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp'
    assert_not_nil assigns(:payment_profiles)
    assert_response :success
  end
  
  test '#add_payment_profile authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :add_payment_profile, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp', :invoice => @valid_params
      assert_not_nil assigns(:payment_profiles)
      assert_response :success
    end
  end

  test '#add_payment_profile does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :add_payment_profile, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp', :invoice => @valid_params
      assert_redirected_to root_url
    end
  end
  
  test "should add invoice item from payment profile to project" do
    post :insert_payment_profiles, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp', :payment_profiles => [payment_profiles(:payment_profiles_001).id]
    
    assert_not_nil assigns(:invoice).invoice_items
    assert_response :success
  end

  test '#insert_payment_profiles authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :insert_payment_profiles, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp', :payment_profiles => [payment_profiles(:payment_profiles_001).id]
      assert_not_nil assigns(:invoice).invoice_items
    assert_response :success
    end
  end

  test '#insert_payment_profiles does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :insert_payment_profiles, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp', :payment_profiles => [payment_profiles(:payment_profiles_001).id]
      assert_redirected_to root_url
    end
  end
  
  test "should show tracked time invoice item form" do
    get :add_tracked_time, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp'
    assert_not_nil assigns(:payment_profiles)
    assert_response :success
  end

  test '#add_tracked_time authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :add_tracked_time, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp'
      assert_not_nil assigns(:payment_profiles)
      assert_response :success
    end
  end

  test '#add_tracked_time does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :add_tracked_time, :project_id => projects(:projects_002), :format => 'js', :currency => 'gbp'
      assert_redirected_to root_url
    end
  end
  
  test "should mark invoice as sent" do
    get :change_status, :project_id => projects(:projects_002), :id => invoices(:invoices_001).id, :status => 1
    assigns(:invoice).reload
    
    assert_equal 1, assigns(:invoice).invoice_status
    assert_response :redirect
  end
  
  test '#change_status authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :change_status, :project_id => projects(:projects_002), :id => invoices(:invoices_001).id, :status => 1
      assigns(:invoice).reload
      assert_equal 1, assigns(:invoice).invoice_status
      assert_response :redirect
    end
  end

  test '#change_status does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :change_status, :project_id => projects(:projects_002), :id => invoices(:invoices_001).id, :status => 1
      assert_redirected_to root_url
    end
  end
  
  test "should mark invoice as paid" do
    get :change_status, :project_id => projects(:projects_002), :id => invoices(:invoices_001).id, :status => 2
    assigns(:invoice).reload
    
    assert_equal 2, assigns(:invoice).invoice_status
    assert_response :redirect
  end
  
  
  test "should mark invoice as paid but fail due to wrong status id passed in" do
    get :change_status, :project_id => projects(:projects_002), :id => invoices(:invoices_001).id, :status => 10
    assigns(:invoice).reload
    
    assert_equal 0, assigns(:invoice).invoice_status
    assert_response :redirect
  end
  
  
  test "should remove invoice" do
    assert_difference 'InvoiceDeletion.all.length', +1 do
      assert_difference 'Invoice.all.length', -1 do
        assert_difference 'InvoiceItem.all.length', -2 do
          delete :destroy, :id => invoices(:invoices_001).id, :project_id => invoices(:invoices_001).project_id
        end
      end
    end
    assert_response :redirect
  end
  
  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'InvoiceDeletion.all.length', +1 do
        assert_difference 'Invoice.all.length', -1 do
          assert_difference 'InvoiceItem.all.length', -2 do
            delete :destroy, :id => invoices(:invoices_001).id, :project_id => invoices(:invoices_001).project_id
          end
        end
      end
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :id => invoices(:invoices_001).id, :project_id => invoices(:invoices_001).project_id
      assert_redirected_to root_url
    end
  end
  
  test "should remove invoice but fail as their are associated usages" do
    invoice_usage = invoices(:invoices_001).invoice_usages.new(:name => 'test', :amount => '1.10')
    invoice_usage.user_id = users(:users_001).id
    invoice_usage.save!
    
    assert_no_difference 'InvoiceDeletion.all.length' do
      assert_no_difference 'Invoice.all.length' do
        delete :destroy, :id => invoices(:invoices_001).id, :project_id => invoices(:invoices_001).project_id
      end
    end
    assert_response :redirect
  end
  
        
end