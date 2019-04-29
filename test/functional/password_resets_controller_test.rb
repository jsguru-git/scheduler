require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
	

    # TODO FIX COPY AND PASTE CODE SPACING/FORMATTING ERRORS. 
    

    def setup
        set_ssl_request
        change_host_to(:accounts_001)
    end     


    #
    # New
    test "should get new" do
        get :new
        assert_response :success
    end

    
    #
    # Create
    test "sucessful send passwrod" do
        post :create,  :user => {:email => users(:users_001).email }
        assert_not_nil flash[:notice].to_s
        assert_response :redirect  
    end


    #
    # Create
    test "insucessful send passwrod" do
        post :create,  :user => {:email => 'tadshfkasdhf@liasjdf.com'}
        assert_not_nil flash[:alert].to_s
        assert_response :success
        assert_template :new
    end


	#
	# Create
    test "send email on successful create" do
        assert_difference 'ActionMailer::Base.deliveries.size', +1 do
            post :create, { :user => { :email => users(:users_001).email } }
        end
    end
	
 
    #
    # Edit
    test "access reset page with valid token" do
    	user = accounts(:accounts_001).users.first
    	user.make_reset_code
        get :edit, { :id => user.password_reset_code }
        assert_response :success
    end


    #
    # Edit
    test "access reset page with invalid token" do
        get :edit, { :id => 'asdfsadf' }
        assert_not_nil flash[:alert].to_s
        assert_response :redirect
    end


    #
    # Update
    test "sucessful reset" do
    	user = accounts(:accounts_001).users.first
    	user.make_reset_code

        post :update, :user => { :password => "password", :password_confirmation => "password" }, :id => user.password_reset_code
        assert_nil session[:user_id]
        assert_not_nil assigns(:user)
        assert_response :redirect
    end


    #
    #
    test "unsucessful update due to validation" do
    	user = accounts(:accounts_001).users.first
    	user.make_reset_code

        post :update, :user => { :password => "passwords", :password_confirmation => "password" }, :id => user.password_reset_code
        assert_not_nil assigns(:user)
        assert_template :edit
    end


    #
    #
    test "unsucessful update due invalid code" do
    	user = accounts(:accounts_001).users.first

        post :update, :user => { :password => "passwords", :password_confirmation => "password" }, :id => 'asdf'
        assert_nil assigns(:user)
        assert_response :redirect
    end


end
