require 'test_helper'
require 'policies/policies_test'

class TrackApi::TimingsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = TrackApi::TimingsController.new
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

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, { user_id: 1 }, :post
  end

  test '#create is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :create, { user_id: 1 }, :post
  end

  test '#create is viewable by leaders' do
    login_as_role :leader
    assert_authorized :create, { user_id: 1 }, :post
  end

  test '#create is viewable by members' do
    login_as_role :member
    assert_authorized :create, { user_id: 1 }, :post
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { user_id: 1, id: 1 }, :put
  end

  test '#update is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :update, { user_id: 1, id: 1 }, :put
  end

  test '#update is viewable by leaders' do
    login_as_role :leader
    assert_authorized :update, { user_id: 1, id: 1 }, :put
  end

  test '#update is viewable by members' do
    login_as_role :member
    assert_authorized :update, { user_id: 1, id: 1 }, :put
  end

  test '#destroy is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :destroy, { user_id: 1, id: 1 }, :delete
  end

  test '#destroy is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :destroy, { user_id: 1, id: 1 }, :delete
  end

  test '#destroy is viewable by leaders' do
    login_as_role :leader
    assert_authorized :destroy, { user_id: 1, id: 1 }, :delete
  end

  test '#destroy is viewable by members' do
    login_as_role :member
    assert_authorized :destroy, { user_id: 1, id: 1 }, :delete
  end

end