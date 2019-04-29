require 'test_helper'

class ProfileAdmin::UsersControllerTest < ActionController::TestCase
    
    
    #
    #
    def setup
        authorize_as_profile_admin
        set_ssl_request
    end
    
    
    #
    #
    test "should get users for a given account" do
        get :index, :account_id => accounts(:accounts_001).id
        assert_response :success
        assert_not_nil assigns(:users)
    end
    
end
