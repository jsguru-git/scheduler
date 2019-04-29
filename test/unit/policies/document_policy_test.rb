require 'test_helper'

class DocumentPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = documents(:documents_001)
  end

  test 'account_holder can create a Document' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator can create a Document' do
    set_role :administrator 
    assert_authorized :create?
  end

  test 'leader cannot create a Document' do
    set_role :leader 
    assert_not_authorized :create?
  end

  test 'member cannot create a Document' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Document' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Document' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader cannot read a Document' do
    set_role :leader 
    assert_not_authorized :read?
  end

  test 'member cannot read a Document' do
    set_role :member 
    assert_not_authorized :read?
  end

  test 'account_holder can update a Document' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator can update a Document' do
    set_role :administrator 
    assert_authorized :update?
  end

  test 'leader cannot update a Document' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Document' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Document' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Document' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Document' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Document' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end

