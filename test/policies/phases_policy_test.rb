require 'test_helper'
require 'policies/policies_test'

class PhasesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    set_ssl_request
    @controller = PhasesController.new
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index
  end

  test '#index is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :index
  end

  test '#index is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :index
  end

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index
  end

  test '#show is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :show, { id: 1 }
  end

  test '#show is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :show, { id: 1 }
  end

  test '#show is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :show, { id: 1 }
  end

  test '#show is not viewable by members' do
    login_as_role :member
    assert_not_authorized :show, { id: 1 }
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, attributes_for(:phase), :post
  end

  test '#create is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :create, attributes_for(:phase), :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, attributes_for(:phase), :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, attributes_for(:phase), :post
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