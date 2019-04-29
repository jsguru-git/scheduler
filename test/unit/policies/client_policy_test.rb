require 'test_helper'

class ClientPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = clients(:clients_001)
  end

  test 'account_holder can create a Client' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator cannot create a Client' do
    set_role :administrator 
    assert_not_authorized :create?
  end

  test 'leader cannot create a Client' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Client' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Client' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Client' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Client' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member can read a Client' do
    set_role :member 
    assert_authorized :read?
  end

  test 'account_holder can update a Client' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Client' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Client' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Client' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Client' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Client' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Client' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Client' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end

