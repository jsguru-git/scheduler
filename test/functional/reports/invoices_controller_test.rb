require 'test_helper'

class Reports::InvoicesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end
  
  
  test "should show invoice status report" do
    get :invoice_status
    assert_not_nil assigns(:invoices)
    assert_response :success
  end

  test '#invoice_status authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :invoice_status
      assert_response :success
    end
  end

  test '#invoice_status does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :invoice_status
      assert_redirected_to root_url
    end
  end
  
  test "should show invoice status report filtered by status" do
    get :invoice_status, :status => 1
    assert_not_nil assigns(:invoices)
    assert_response :success
  end
  
  test "should get payment predictions report" do
    get :payment_predictions, :status => 1
    
    assert_not_nil assigns(:results)
    assert_not_nil assigns(:cal)
    
    assert_equal Time.now.to_date.beginning_of_month, assigns(:cal).start_date
    assert_response :success
  end

  test '#payment_predictions authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :payment_predictions, :status => 1
      assert_response :success
    end
  end

  test '#payment_predictions does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :payment_predictions, :status => 1
      assert_redirected_to root_url
    end
  end

  test "should show deletion invoice report" do
    get :deletions
    assert_not_nil assigns(:invoice_deletions)
    assert_response :success
  end

  test '#deletions authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :deletions
      assert_response :success
    end
  end

  test '#deletions does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :deletions
      assert_redirected_to root_url
    end
  end

  test "should show normalised monthly invoice report" do
    get :normalised_monthly
    assert_not_nil assigns(:cal)
    assert_response :success
  end

  test '#normalised_monthly authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :normalised_monthly
      assert_response :success
    end
  end

  test '#normalised_monthly does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :normalised_monthly
      assert_redirected_to root_url
    end
  end

  test "should get combined pre payments report" do
    get :combined_pre_payments
    
    assert_not_nil assigns(:results)
    assert_not_nil assigns(:cal)
    assert_response :success
  end

  test '#combined_pre_payments authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :combined_pre_payments
      assert_response :success
    end
  end

  test '#combined_pre_payments does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :combined_pre_payments
      assert_redirected_to root_url
    end
  end

  test '#allocation_breakdown authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :allocation_breakdown
      assert_response :success
    end
  end

  test '#allocation_breakdown does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :allocation_breakdown
      assert_redirected_to root_url
    end
  end
  
  
end
