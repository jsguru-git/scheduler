require 'test_helper'
require 'policies/policies_test'

class Quote::ProjectsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Quote::ProjectsController.new
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

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index
  end

  test '#search is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :search
  end

  test '#search is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :search
  end

  test '#search is viewable by leaders' do
    login_as_role :leader
    assert_authorized :search
  end

  test '#search is not viewable by members' do
    login_as_role :member
    assert_not_authorized :search
  end

 
end