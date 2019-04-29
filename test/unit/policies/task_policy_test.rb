require 'test_helper'

class TaskPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = build(:task)
  end

  test 'account_holder can create a Task' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator cannot create a Task' do
    set_role :administrator 
    assert_not_authorized :create?
  end

  test 'leader cannot create a Task' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Task' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Task' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Task' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Task' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member cannot read a Task' do
    set_role :member 
    assert_not_authorized :read?
  end

  test 'account_holder can update a Task' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Task' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Task' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Task' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Task' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Task' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Task' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Task' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end

