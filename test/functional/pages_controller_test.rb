require 'test_helper'

class PagesControllerTest < ActionController::TestCase
    

    test "Render Homepage" do
        get :index
        assert_response :success
    end
    

    test "Signup" do
        get :signup
        assert_response :success
        assert_not_nil assigns(:account_plans)
    end
    

    test "Privacy" do
        get :privacy
        assert_response :success
    end
    
 
    test "Terms" do
        get :terms
        assert_response :success
    end


    test "Schedule" do
        get :scheduling_tool
        assert_response :success
    end
    
    
    test "quote" do
        get :quote_tool
        assert_response :success
    end
    

    test "time tracking" do
        get :time_tracking_tool
        assert_response :success
    end  
    
    test "invoice" do
        get :invoice_tool
        assert_response :success
    end
    
    test "thanks" do
      get :thanks, account_name: accounts(:accounts_001).site_address
      assert_response :success
    end
end