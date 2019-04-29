require 'test_helper'

class AccountSettingsControllerTest < ActionController::TestCase


  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder]
  end


  # Index
  test "render index" do
    get :index
    assert_not_nil assigns(:account_plans)
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
      
  test "#change_plan for non chargify account" do
    change_host_to(:accounts_004)
    login_as(:users_004)

    put :change_plan, { :account => {:account_plan_id => '3' }}
    assert_response :redirect
  end

  test '#change_plan authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :change_plan, { account: { account_plan_id: 3 } }
      assert_response :redirect
    end
  end

  test '#change_plan does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :change_plan, { account: { account_plan_id: 3 } }
      assert_redirected_to root_url
    end
  end

  test "failed update" do
    change_host_to(:accounts_003)
    login_as(:users_003)
    Account.any_instance.expects(:update_plan_to).returns(false)
    put :change_plan, { :account => {:account_plan_id => '3' }}
    assert_not_nil flash[:alert].to_s
    assert_redirected_to account_settings_path
  end

  # Confirm remove
  test "confirm remove account page2" do
    get :confirm_remove, nil, { :user_id => 2 }
    assert_response :success
  end

  test '#confirm_remove authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :confirm_remove, nil, { user_id: 2 }
      assert_response :success
    end
  end

  test '#confirm_remove does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :confirm_remove, nil, { user_id: 2 }
      assert_redirected_to root_url
    end
  end

  test "remove account" do
    delete :destroy, :id => accounts(:accounts_001).id
    assert_not_nil assigns(:account)
    assert_not_nil assigns(:account).account_deleted_at
    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      new_account = create(:account)
      delete :destroy, id: new_account.id
      assert_not_nil assigns(:account)
      assert_not_nil assigns(:account).account_deleted_at
      assert_response :redirect
    end
  end

  # Payment Details
  test "payment details" do
    get :payment_details, nil, { :user_id => 1 }
    assert_response :success
  end

  test '#payment_details authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :payment_details, nil, { user_id: 1 }
      assert_response :success
    end
  end

  test '#payment_details does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :payment_details, nil, { user_id: 1 }
      assert_redirected_to root_url
    end
  end

  test "payment details from update" do
    get :payment_details, {:updated => "1"}
    assert flash[:notice]
    assert_response :success
  end

  # Statements
  test "get statements" do
    get :statements, nil, { :user_id => 1 }
    assert_response :success
  end

  test '#statements authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :statements, nil, { user_id: 1 }
      assert_response :success
    end
  end

  test '#statements does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :statements, nil, { user_id: 1 }
      assert_redirected_to root_url
    end
  end
    
  # Statement
  test "get a single statement" do
    Account.any_instance.expects(:get_single_statement).returns(nil)
    get :statement
    assert_response :success
  end

  test '#statement authorizes permitted' do
    @permitted.each do |role|
      Account.any_instance.stubs(:get_single_statement).returns(nil)
      login_as_role role
      get :statement
      assert_response :success
    end
  end

  test '#statement does not allow excluded' do
    (roles - @permitted).each do |role|
      Account.any_instance.stubs(:get_single_statement).returns(nil)
      login_as_role role
      get :statement
      assert_redirected_to root_url
    end
  end

  # enable_component
  test "should enable plan" do
    change_host_to(:accounts_002)
    login_as(:users_002)

    assert_difference 'AccountAccountComponent.all.size', +1 do
      put :enable_component, :component_id => account_components(:one).id
    end
  end

  test '#enable_component authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :enable_component, component_id: account_components(:one).id
      assert_response :redirect
    end
  end

  test '#enable_component does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :enable_component, component_id: account_components(:one).id
      assert_redirected_to root_url
    end
  end
    
  # enable_component
  test "should not create another component if already enabled" do
    assert_no_difference 'AccountAccountComponent.all.size' do
      put :enable_component, :component_id => account_components(:one).id
    end
  end


  # disable_component
  test "should disable plan but fail due to existing data" do
    assert_no_difference 'AccountAccountComponent.all.size' do
      put :disable_component, :component_id => account_components(:one).id
    end
  end


  # disable_component
  test "should disable component but fail as there must be more than one component enabled" do
    accounts(:accounts_003).account_components << account_components(:one)
    change_host_to(:accounts_003)
    login_as(:users_003)

    assert_no_difference 'AccountAccountComponent.all.size' do
      put :disable_component, :component_id => account_components(:one).id
    end
  end


  # disable_component
  test "should disable component" do
    accounts(:accounts_003).account_components << account_components(:one)
    accounts(:accounts_003).account_components << account_components(:two)
    change_host_to(:accounts_003)
    login_as(:users_003)

    assert_difference 'AccountAccountComponent.all.size', -1 do
      put :disable_component, :component_id => account_components(:one).id
    end
  end

  test '#disable_component authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      
      accounts(:accounts_003).account_components << account_components(:one)
      accounts(:accounts_003).account_components << account_components(:two)
      change_host_to(:accounts_003)
      login_as(:users_003)

      assert_difference 'AccountAccountComponent.all.size', -1 do
        put :disable_component, :component_id => account_components(:one).id
      end
    end
  end

  test '#disable_component does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :disable_component, :component_id => account_components(:one).id
      assert_redirected_to root_url
    end
  end
    
end
