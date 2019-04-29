require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
    

    def setup
        set_ssl_request
        change_host_to(:accounts_001)
    end
    
    
    # New
    test 'new' do
        get :new
        assert :success
    end
    
    
    # Destroy
    test 'destroy' do
        login_as(:users_001)
        get :destroy
        assert_not_nil flash[:notice].to_s
        assert_response :redirect
    end
    

    test "should try to login but fail as no user found" do
        post :create, :email => 'test@test.com', :password => 'tester'
        assert :success
    end


    test "should try to login but fail as incorrect password" do
        post :create, :email => 'scott@arthurly.com', :password => 'tester'
        assert :success
    end


    test "should try to login and succeeded" do
        post :create, :email => 'scott@arthurly.com', :password => 'testtt'
        assert :redirect
    end
end
