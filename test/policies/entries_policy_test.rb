require 'test_helper'
require 'policies/policies_test'

class EntriesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = EntriesController.new
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

end