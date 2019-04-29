require 'test_helper'

class PaymentProfilePolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = payment_profiles(:payment_profiles_001)
  end

  test 'account_holder can create a Payment_profile' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator cannot create a Payment_profile' do
    set_role :administrator 
    assert_not_authorized :create?
  end

  test 'leader cannot create a Payment_profile' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Payment_profile' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Payment_profile' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Payment_profile' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader cannot read a Payment_profile' do
    set_role :leader 
    assert_not_authorized :read?
  end

  test 'member cannot read a Payment_profile' do
    set_role :member 
    assert_not_authorized :read?
  end

  test 'account_holder can update a Payment_profile' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Payment_profile' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Payment_profile' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Payment_profile' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Payment_profile' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Payment_profile' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Payment_profile' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Payment_profile' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end
