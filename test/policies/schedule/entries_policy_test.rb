require 'test_helper'
require 'policies/policies_test'

class Schedule::EntriesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Schedule::EntriesController.new
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

  test '#lead_time is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :lead_time
  end

  test '#lead_time is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :lead_time
  end

  test '#lead_time is viewable by leaders' do
    login_as_role :leader
    assert_authorized :lead_time
  end

  test '#lead_time is not viewable by members' do
    login_as_role :member
    assert_not_authorized :lead_time
  end

end