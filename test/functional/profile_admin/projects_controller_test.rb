require 'test_helper'

class ProfileAdmin::ProjectsControllerTest < ActionController::TestCase
    
    
    #
    #
    def setup
        authorize_as_profile_admin
        set_ssl_request
    end
    
    
    #
    #
    test "should get projects for a given account" do
        get :index, :account_id => accounts(:accounts_001).id
        assert_response :success
        assert_not_nil assigns(:projects)
    end
    
    
    
end
