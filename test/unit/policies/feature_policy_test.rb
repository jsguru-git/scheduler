require 'test_helper'

class FeaturePolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = features(:features_001)
  end

  test 'account_holder can create a Feature' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator cannot create a Feature' do
    set_role :administrator 
    assert_not_authorized :create?
  end

  test 'leader cannot create a Feature' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Feature' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Feature' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Feature' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Feature' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member cannot read a Feature' do
    set_role :member 
    assert_not_authorized :read?
  end

  test 'account_holder can update a Feature' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Feature' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Feature' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Feature' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Feature' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Feature' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Feature' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Feature' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end
