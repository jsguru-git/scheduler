# Report generator tests

require 'test_helper'
require 'schedule_notifier'

class ScheduleNotifierTest < ActiveSupport::TestCase

  def setup
    @schedule_notifier = ScheduleNotifier.new
  end

  test 'initialize return a new instance' do
    assert_equal ScheduleNotifier, @schedule_notifier.class
  end

  test 'can assign :user to a ScheduleNotifier' do
    user = FactoryGirl.build(:user)
    @schedule_notifier.user = user
    assert_match /firstname1\d/, @schedule_notifier.user.firstname
  end

end

