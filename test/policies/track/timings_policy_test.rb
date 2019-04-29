require 'test_helper'
require 'policies/policies_test'

class Track::TimingsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Track::TimingsController.new
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

  test '#submit_time is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :submit_time, { user_id: 1, date: Date.today }
  end

  test '#submit_time is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :submit_time, { user_id: 1, date: Date.today }
  end

  test '#submit_time is viewable by leaders' do
    login_as_role :leader
    assert_authorized :submit_time, { user_id: 1, date: Date.today }
  end

  test '#submit_time is viewable by members' do
    login_as_role :member
    assert_authorized :submit_time, { user_id: 1, date: Date.today }
  end

  test '#submitted_time_report is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :submitted_time_report, { user_id: 1 }
  end

  test '#submitted_time_report is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :submitted_time_report, { user_id: 1 }
  end

  test '#submitted_time_report is viewable by leaders' do
    login_as_role :leader
    assert_authorized :submitted_time_report, { user_id: 1 }
  end

  test '#submitted_time_report is viewable by members' do
    login_as_role :member
    assert_authorized :submitted_time_report, { user_id: 1 }
  end

end