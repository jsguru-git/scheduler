require 'test_helper'

class UsersControllerTest < ActionController::TestCase


  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)

    @valid_parameters = { :user => {:firstname => 'Joe', :lastname => 'Bloggs', :email => 'info@bloggs.com', :password => 'password'}, :send_invite_email => 1}
  end


  test "index loads pages" do
    get :index
    assert :success
    assert_not_nil assigns(:users)
  end


  #
  # New
  test 'new page' do
    get :new
    assert :success
    assert assigns('user').new_record? == true
  end


  #
  # Create
  test "sucessful create" do
    assert_difference 'User.all.size', +1 do
      post :create, @valid_parameters
    end
    assert_not_nil flash[:notice].to_s
    assert_response :redirect
  end


  test "unsucessful create" do
    post :create,  :user => {:firstname => 'Joe', :lastname => 'Bloggs', :email => 'info@bloggs.com', :password => ''}
    assert_template :new
  end


  test "send notification email" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :create, @valid_parameters
    end
  end

  test "create sets the role to 'member' if the account has an existing user" do
    post :create, @valid_parameters
    assert_equal ['member'], assigns(:user).roles.map(&:title)
  end

  #
  # Edit
  test 'edit page' do
    get :edit, :id => users(:users_001).id
    assert_not_nil assigns('user')
    assert_response :success
  end


  test 'cant access edit page for another account' do
    assert_raise ActiveRecord::RecordNotFound do
      get :edit, :id => users(:users_002).id
    end
  end


  #
  # Update
  test "successful update" do
    request.env["HTTP_REFERER"] = root_url
    post :update, :id => users(:users_001).id, :user => {:firstname => 'test new name'}
    assert_not_nil flash[:notice].to_s
    assert_response :redirect
  end


  test "unsuccessful update" do
    post :update, :id => users(:users_001).id, :user => {:firstname => ''}
    assert_template :edit
  end


  #
  # Delete
  test "delete record" do
    assert_difference 'User.all.length', -1 do
      delete :destroy, :id => users(:users_006)
    end
    assert_raise(ActiveRecord::RecordNotFound) { User.find(users(:users_006).id) }
  end


  test "unable to delete current user" do
    delete :destroy, :id => users(:users_001).id
    assert_nothing_raised { User.find(users(:users_001).id) }
  end

  # Update Roles
  test "update_roles does not allow administrators to set anyone's role to account_holder" do
    login_as_role :administrator
    put :update_roles, { user_id: users(:users_001).id, role_id: Role.find_by_title('account_holder').id, format: :json }
    assert_response :forbidden
  end

  #
  # Edit Role
  test "edit roles" do
    login_as_role :account_holder
    get :edit_roles
    assert_not_nil assigns(:users)
    assert_template :edit_roles
  end

  test '#edit always authorizes for the current user' do
    login_as_role :member
    get :edit, :id => users(:users_001).id
    assert_response :success
  end

  #
  # Show Role
  test "show user" do
    unset_ssl_request
    get :show, :id => users(:users_001).id
    assert_not_nil assigns(:user)
  end

  test '#update_roles does not allow the only account_holder to be changed to another status' do
    post :update_roles, { user_id: users(:users_001).id, role_id: 4, format: :json }
    assert_response :unprocessable_entity
  end
end
