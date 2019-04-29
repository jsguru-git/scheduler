require 'test_helper'

class AccountsControllerTest < ActionController::TestCase


  def setup
    set_ssl_request
    @valid_parameters = { :account => { :users_attributes => { "0" => { :firstname => 'Joe', :lastname => 'Bloggs', :email => 'info@bloggs.com', :password => 'password', :password_confirmation => 'password' }}, :site_address => 'new' }, :plan_id => account_plans(:account_plans_001).id, :component_id => [account_components(:one).id] }
  end


  # Filters
  test "Succeed find_plans before filter" do
    get :new, { :plan_id => account_plans(:account_plans_001).id, 'component_id' => account_components(:one).id  }
    assert_response :success
    assert_not_nil assigns(:account_plan)
  end


  test "Raise error in find_plans before filter" do
    assert_raise ActiveRecord::RecordNotFound do
      get :new, { :plan_id => "435", 'component_id' => account_components(:one).id  }
    end
  end


  # New


  test "New" do
    get :new, { :plan_id => account_plans(:account_plans_001).id, 'component_id' => account_components(:one).id }
    assert assigns(:account).new_record?
    assert :success
  end


  # verify_suite


  test "check valid suite details but fail" do
    post :verify_suite
    assert_not_nil flash[:alert]
    assert :redirect
  end


  test "check valid suite details" do
    post :verify_suite, { :plan_id => account_plans(:account_plans_001).id, 'component_id' => account_components(:one).id  }
    assert_nil flash[:alert]
    assert :redirect
  end


  # Create


  test "saves account" do
    assert_difference 'Account.all.size', +1 do
      assert_difference 'AccountSetting.all.size', +1 do
        assert_difference 'AccountTrialEmail.all.size', +1 do
          assert_difference 'User.all.size', +1 do
            assert_difference 'Project.all.size', +1 do
              assert_difference 'QuoteDefaultSection.all.size', +3 do
                post :create, @valid_parameters
              end
            end
          end
        end
      end
    end
  end


  test "email customer" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :create, @valid_parameters
      mail = ActionMailer::Base.deliveries.last
      assert mail.subject.include?('Thanks for joining')
    end
  end


  test "Redirect to site on free plan" do
    post :create, @valid_parameters
    assert_redirected_to thankyou_path(:account_name => 'new')
  end


  # Create: Paid account
  test "Redirect to account page for start of free trial" do
    @valid_parameters[:plan_id] = account_plans(:account_plans_002).id
    post :create, @valid_parameters
    assert_response :redirect
  end


  # Create: Failed save
  test "Render new on failed create" do
    post :create, { :account => { :users_attributes => { "0" => { :firstname => 'Joe', :lastname => 'Bloggs', :email => 'sam@palebluedigital.com', :password => 'password', :password_confirmation => 'password' }}, :site_address => "test" }, :plan_id => account_plans(:account_plans_001).id, 'component_id' => account_components(:one).id }
    assert_template :new
  end


end
