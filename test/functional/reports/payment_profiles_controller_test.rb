require 'test_helper'

class Reports::PaymentProfilesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end

  test "should get rollover report" do
    get :rollover
    assert_not_nil assigns(:payment_profile_rollovers)
    assert_response :success
  end
  
  test '#rollover authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :rollover
      assert_response :success
    end
  end

  test '#rollover does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :rollover
      assert_redirected_to root_url
    end
  end
  
end
