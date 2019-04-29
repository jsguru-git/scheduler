require 'test_helper'

class UserPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = build(:user)
  end

  test 'account_holder can create a User' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator can create a User' do
    set_role :administrator 
    assert_authorized :create?
  end

  test 'leader cannot create a User' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a User' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a User' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a User' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a User' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member can read a User' do
    set_role :member 
    assert_authorized :read?
  end

  test 'account_holder can update a User' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator can update a User' do
    set_role :administrator 
    assert_authorized :update?
  end

  test 'leader cannot update a User that isnt themselves' do
    a = create(:user, roles: [create(:role, :leader)])
    b = create(:user, roles: [create(:role, :leader)])
    assert_equal false, Pundit.policy(a, b).update?
  end

  test 'member cannot update a User that isnt themselves' do
    a = create(:user, roles: [create(:role, :member)])
    b = create(:user, roles: [create(:role, :member)])
    assert_equal false, Pundit.policy(a, b).update?
  end

  test 'account_holder can destroy a User' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator can destroy a User' do
    set_role :administrator 
    assert_authorized :destroy?
  end

  test 'leader cannot destroy a User' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a User' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end
