require 'test_helper'

class EntryPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = entries(:entries_001)
  end

  test 'account_holder can create a Entry' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator can create a Entry' do
    set_role :administrator 
    assert_authorized :create?
  end

  test 'leader cannot create a Entry' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Entry' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Entry' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Entry' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Entry' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member can read a Entry' do
    set_role :member 
    assert_authorized :read?
  end

  test 'account_holder can update a Entry' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator can update a Entry' do
    set_role :administrator 
    assert_authorized :update?
  end

  test 'leader cannot update a Entry' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Entry' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Entry' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator can destroy a Entry' do
    set_role :administrator 
    assert_authorized :destroy?
  end

  test 'leader cannot destroy a Entry' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Entry' do
    set_role :member 
    assert_not_authorized :destroy?
  end

  test 'account_holder can report a Entry' do
    set_role :account_holder 
    assert_authorized :report?
  end

  test 'administrator can report a Entry' do
    set_role :administrator 
    assert_authorized :report?
  end

  test 'leader can report a Entry' do
    set_role :leader 
    assert_authorized :report?
  end

  test 'member cannot report a Entry' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end

