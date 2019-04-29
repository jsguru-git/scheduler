require 'test_helper'

class TimingPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = timings(:one)
  end

  test 'account_holder can create a Timing' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator can create a Timing' do
    set_role :administrator 
    assert_authorized :create?
  end

  test 'leader can create a Timing' do
    set_role :leader 
    assert_authorized :create?
  end

  test 'member can create a Timing' do
    set_role :member 
    assert_authorized :create?
  end

  test 'account_holder can read a Timing' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Timing' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Timing' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member can read a Timing' do
    set_role :member 
    assert_authorized :read?
  end

  test 'account_holder can update a Timing' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator can update a Timing' do
    set_role :administrator 
    assert_authorized :update?
  end

  test 'leader can update a Timing' do
    set_role :leader 
    assert_authorized :update?
  end

  test 'member can update a Timing' do
    set_role :member 
    assert_authorized :update?
  end

  test 'account_holder can destroy a Timing' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator can destroy a Timing' do
    set_role :administrator 
    assert_authorized :destroy?
  end

  test 'leader can destroy a Timing' do
    set_role :leader 
    assert_authorized :destroy?
  end

  test 'member can destroy a Timing' do
    set_role :member 
    assert_authorized :destroy?
  end

end
