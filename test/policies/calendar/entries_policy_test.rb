require 'test_helper'
require 'policies/policies_test'

class Calendars::EntriesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Calendars::EntriesController.new
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

  test '#entries_for_user is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :entries_for_user
  end

  test '#entries_for_user is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :entries_for_user
  end

  test '#entries_for_user is viewable by leaders' do
    login_as_role :leader
    assert_authorized :entries_for_user
  end

  test '#entries_for_user is viewable by members' do
    login_as_role :member
    assert_not_authorized :entries_for_user
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create
  end

  test '#create is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :create
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { id: 1 }
  end

  test '#update is viewable by administrators' do
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
    assert_authorized :destroy, { id: 1 }
  end

  test '#destroy is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :destroy, { id: 1 }
  end

  test '#destroy is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :destroy, { id: 1 }
  end

  test '#destroy is not viewable by members' do
    login_as_role :member
    assert_not_authorized :destroy, { id: 1 }
  end

end