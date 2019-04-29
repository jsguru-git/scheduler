# How to test Policies
#
# Create a subclass of this class and define @user and @object in the setup method.
#
#  def setup
#    @user = build(:user)
#    @object = clients(:clients_001)
#  end
#
# Where @user is just a built user and @object is the object who's Policy
# you are testing.
#
# Each test should then just look like this:
#
# test 'account_holder can create a Client' do
#   set_role :account_holder 
#   assert_authorized :create?
# end

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase

  def set_role(role)
    User.any_instance.stubs(:roles).returns([build(:role, role)])
  end

  def assert_authorized(action)
    assert_equal true, Pundit.policy(@user, @object).send(action)
  end

  def assert_not_authorized(action)
    assert_equal false, Pundit.policy(@user, @object).send(action)
  end

end