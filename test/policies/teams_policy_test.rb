require 'test_helper'
require 'policies/policies_test'

class TeamsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    set_ssl_request
    @controller = TeamsController.new
  end



  test '#show is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by leaders' do
    login_as_role :leader
    assert_authorized :show, { id: 1 }
  end

  test '#show is not viewable by members' do
    login_as_role :member
    assert_not_authorized :show, { id: 1 }
  end

  test '#new is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new
  end

  test '#new is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :new
  end

  test '#new is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :new
  end

  test '#new is not viewable by members' do
    login_as_role :member
    assert_not_authorized :new
  end

  test '#edit is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit, { id: 1 }
  end

  test '#edit is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :edit, { id: 1 }
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
    assert_authorized :update, { id: 1 }, :put
  end

  test '#update is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :update, { id: 1 }, :put
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { id: 1 }, :put
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { id: 1 }, :put
  end

  test '#destroy is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :destroy, { id: 1 }, :delete
  end

  test '#destroy is not viewable by members' do
    login_as_role :member
    assert_not_authorized :destroy, { id: 1 }, :delete
  end
  
end