require 'test_helper'
require 'policies/policies_test'

class ClientsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = ClientsController.new
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

  test '#show is viewable by members' do
    login_as_role :member
    assert_authorized :show, { id: 1 }
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { id: 1, client: { name: 'example' } }, :put
  end

  test '#update is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :update, { id: 1, client: { name: 'example' } }, :put
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { id: 1, client: { name: 'example' } }, :put
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { id: 1, client: { name: 'example' } }, :put
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, { client: { name: 'example' } }, :post
  end

  test '#create is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :create, { client: { name: 'example' } }, :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, { client: { name: 'example' } }, :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, { client: { name: 'example' } }, :post
  end

  test '#archive is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :archive, { id: 1 }, :put
  end

  test '#archive is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :archive, { id: 1 }, :put
  end

  test '#archive is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :archive, { id: 1 }, :put
  end

  test '#archive is not viewable by members' do
    login_as_role :member
    assert_not_authorized :archive, { id: 1 }, :put
  end

  test '#activate is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by members' do
    login_as_role :member
    assert_not_authorized :activate, { id: 1 }, :put
  end
 
end