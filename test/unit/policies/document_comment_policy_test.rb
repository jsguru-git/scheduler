require 'test_helper'

class DocumentCommentPolicyTest < PolicyTest

  def setup
    @user = build(:user)
    @object = document_comments(:document_comments_001)
  end

  test 'account_holder can create a Comment' do
    set_role :account_holder 
    assert_authorized :create?
  end

  test 'administrator can create a Comment' do
    set_role :administrator 
    assert_authorized :create?
  end

  test 'leader can create a Comment' do
    set_role :leader 
    assert_authorized :create?
  end

  test 'member cannot create a Comment' do
    set_role :member 
    assert_not_authorized :create?
  end

  test 'account_holder can read a Comment' do
    set_role :account_holder 
    assert_authorized :read?
  end

  test 'administrator can read a Comment' do
    set_role :administrator 
    assert_authorized :read?
  end

  test 'leader can read a Comment' do
    set_role :leader 
    assert_authorized :read?
  end

  test 'member cannot read a Comment' do
    set_role :member 
    assert_not_authorized :read?
  end

  test 'account_holder can update a Comment' do
    set_role :account_holder 
    assert_authorized :update?
  end

  test 'administrator cannot update a Comment' do
    set_role :administrator 
    assert_not_authorized :update?
  end

  test 'leader cannot update a Comment' do
    set_role :leader 
    assert_not_authorized :update?
  end

  test 'member cannot update a Comment' do
    set_role :member 
    assert_not_authorized :update?
  end

  test 'account_holder can destroy a Comment' do
    set_role :account_holder 
    assert_authorized :destroy?
  end

  test 'administrator cannot destroy a Comment' do
    set_role :administrator 
    assert_not_authorized :destroy?
  end

  test 'leader cannot destroy a Comment' do
    set_role :leader 
    assert_not_authorized :destroy?
  end

  test 'member cannot destroy a Comment' do
    set_role :member 
    assert_not_authorized :destroy?
  end

end
