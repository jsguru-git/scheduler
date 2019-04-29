require 'test_helper'

class ProfileAdmin::AccountsControllerTest < ActionController::TestCase
    
    
    #
    #
    def setup
        authorize_as_profile_admin
        set_ssl_request
    end
    
    
    #
    #
    test "should get admin index" do
        get :index
        assert_response :success
        assert_not_nil assigns(:accounts)
    end
    
    
end
