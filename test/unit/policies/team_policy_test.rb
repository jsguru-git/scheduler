require 'test_helper'

class TeamPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = teams(:teams_001)
  end

  test 'account_holder can create a Team' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator cannot create a Team' do
    set_role :administrator 
    assert_not_authorized :create?
  end

  test 'leader cannot create a Team' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Team' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Team' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Team' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Team' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member can read a Team' do
    set_role :member 
    assert_authorized :read?
  end

  test 'account_holder can update a Team' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Team' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Team' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Team' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Team' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Team' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Team' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Team' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end
