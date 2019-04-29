require 'test_helper'
require 'policies/policies_test'

class UsersPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    set_ssl_request
    @controller = UsersController.new
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index
  end

  test '#index is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :index
  end

  test '#index is viewable by leaders' do
    login_as_role :leader
    assert_authorized :index
  end

  test '#index is viewable by members' do
    login_as_role :member
    assert_authorized :index
  end

  test '#show is viewable by account_holders' do
    unset_ssl_request
    login_as_role :account_holder
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by administrators' do
    unset_ssl_request
    login_as_role :administrator
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by leaders' do
    unset_ssl_request
    login_as_role :leader
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by members' do
    unset_ssl_request
    login_as_role :member
    assert_authorized :new
  end

  test '#new is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new
  end

  test '#new is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :new
  end

  test '#new is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :new
  end

  test '#new is not viewable by members' do
    login_as_role :member
    assert_not_authorized :new
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, { user: attributes_for(:user) }
  end

  test '#create is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :create, { user: attributes_for(:user) }
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, { user: attributes_for(:user) }
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, { user: attributes_for(:user) }
  end

  test '#edit is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit, { id: 1 }
  end

  test '#edit is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :edit, { id: 1 }
  end

  test '#edit is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :edit, { id: 1 }
  end

  test '#edit is not viewable by members' do
    login_as_role :member
    assert_not_authorized :edit, { id: 1 }
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit, { id: 1 }
  end

  test '#update is viewable by administrators' do
    @request.env['HTTP_REFERER'] = 'http://example.com'
    login_as_role :administrator
    assert_authorized :update, { id: 1 }
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { id: 1 }
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { id: 1 }
  end

  test '#destroy is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is not viewable by members' do
    login_as_role :member
    assert_not_authorized :destroy, { id: 1 }, :delete
  end

  test '#edit_roles is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit_roles
  end

  test '#edit_roles is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :edit_roles
  end

  test '#edit_roles is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :edit_roles
  end

  test '#edit_roles is not viewable by members' do
    login_as_role :member
    assert_not_authorized :edit_roles
  end

  test '#update_roles is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update_roles, { user_admins: [create(:user, account_id: 1)] }
  end

  test '#update_roles is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :update_roles, { user_admins: [create(:user, account_id: 1)] }
  end

  test '#update_roles is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update_roles, { user_admins: [create(:user, account_id: 1)] }
  end

  test '#update_roles is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update_roles, { user_admins: [create(:user, account_id: 1)] }
  end

end